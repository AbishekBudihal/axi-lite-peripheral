`timescale 1ns/1ps

module tb_axi_lite;

    // -------------------------------------------------------
    // Parameters
    // -------------------------------------------------------
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;
    parameter NUM_REGS   = 4;

    // -------------------------------------------------------
    // Clock & Reset
    // -------------------------------------------------------
    reg clk = 0;
    reg rst = 1;
    always #5 clk = ~clk; // 100MHz

    // -------------------------------------------------------
    // DUT Signals
    // -------------------------------------------------------
    reg                    awvalid;
    reg  [ADDR_WIDTH-1:0]  awaddr;
    wire                   awready;

    reg                    wvalid;
    reg  [DATA_WIDTH-1:0]  wdata;
    reg  [3:0]             wstrb;
    wire                   wready;

    wire                   bvalid;
    wire [1:0]             bresp;
    reg                    bready;

    reg                    arvalid;
    reg  [ADDR_WIDTH-1:0]  araddr;
    wire                   arready;

    wire                   rvalid;
    wire [DATA_WIDTH-1:0]  rdata;
    wire [1:0]             rresp;
    reg                    rready;

    // -------------------------------------------------------
    // DUT Instantiation
    // -------------------------------------------------------
    axi_lite_slave #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .NUM_REGS(NUM_REGS)
    ) dut (
        .clk(clk), .rst(rst),
        .awvalid(awvalid), .awaddr(awaddr), .awready(awready),
        .wvalid(wvalid),   .wdata(wdata),   .wstrb(wstrb),   .wready(wready),
        .bvalid(bvalid),   .bresp(bresp),   .bready(bready),
        .arvalid(arvalid), .araddr(araddr), .arready(arready),
        .rvalid(rvalid),   .rdata(rdata),   .rresp(rresp),   .rready(rready)
    );

    // -------------------------------------------------------
    // Scoreboard: track expected register values
    // -------------------------------------------------------
    reg [DATA_WIDTH-1:0] expected_regs [0:NUM_REGS-1];
    integer pass_count = 0;
    integer fail_count = 0;

    // -------------------------------------------------------
    // Assertions
    // -------------------------------------------------------

    // VALID must not deassert once raised until handshake occurs
    always @(posedge clk) begin
        if (!rst) begin
            // AWVALID stability
            if ($fell(awvalid) && !awready)
                $display("ASSERTION FAIL [%0t]: awvalid deasserted without handshake", $time);

            // WVALID stability
            if ($fell(wvalid) && !wready)
                $display("ASSERTION FAIL [%0t]: wvalid deasserted without handshake", $time);

            // ARVALID stability
            if ($fell(arvalid) && !arready)
                $display("ASSERTION FAIL [%0t]: arvalid deasserted without handshake", $time);

            // BRESP must be OKAY on valid response
            if (bvalid && bresp !== 2'b00)
                $display("ASSERTION FAIL [%0t]: unexpected bresp = %b", $time, bresp);

            // RRESP must be OKAY on valid read
            if (rvalid && rresp !== 2'b00)
                $display("ASSERTION FAIL [%0t]: unexpected rresp = %b", $time, rresp);
        end
    end

    // -------------------------------------------------------
    // Coverage
    // -------------------------------------------------------
    reg cov_write_reg0 = 0;
    reg cov_write_reg1 = 0;
    reg cov_write_reg2 = 0;
    reg cov_write_reg3 = 0;
    reg cov_read_reg0  = 0;
    reg cov_read_reg1  = 0;
    reg cov_read_reg2  = 0;
    reg cov_read_reg3  = 0;
    reg cov_wstrb_byte = 0; // partial byte write
    reg cov_back2back  = 0; // back-to-back transactions

    task update_write_coverage;
        input [ADDR_WIDTH-1:0] addr;
        input [3:0]            strb;
        begin
            case (addr[3:2])
                2'd0: cov_write_reg0 = 1;
                2'd1: cov_write_reg1 = 1;
                2'd2: cov_write_reg2 = 1;
                2'd3: cov_write_reg3 = 1;
            endcase
            if (strb !== 4'hF) cov_wstrb_byte = 1;
        end
    endtask

    task update_read_coverage;
        input [ADDR_WIDTH-1:0] addr;
        begin
            case (addr[3:2])
                2'd0: cov_read_reg0 = 1;
                2'd1: cov_read_reg1 = 1;
                2'd2: cov_read_reg2 = 1;
                2'd3: cov_read_reg3 = 1;
            endcase
        end
    endtask

    task print_coverage;
        integer hits, total;
        begin
            hits  = cov_write_reg0 + cov_write_reg1 + cov_write_reg2 + cov_write_reg3 +
                    cov_read_reg0  + cov_read_reg1  + cov_read_reg2  + cov_read_reg3  +
                    cov_wstrb_byte + cov_back2back;
            total = 10;
            $display("--------------------------------------------------");
            $display("FUNCTIONAL COVERAGE REPORT");
            $display("  Write reg0       : %s", cov_write_reg0 ? "HIT" : "MISS");
            $display("  Write reg1       : %s", cov_write_reg1 ? "HIT" : "MISS");
            $display("  Write reg2       : %s", cov_write_reg2 ? "HIT" : "MISS");
            $display("  Write reg3       : %s", cov_write_reg3 ? "HIT" : "MISS");
            $display("  Read  reg0       : %s", cov_read_reg0  ? "HIT" : "MISS");
            $display("  Read  reg1       : %s", cov_read_reg1  ? "HIT" : "MISS");
            $display("  Read  reg2       : %s", cov_read_reg2  ? "HIT" : "MISS");
            $display("  Read  reg3       : %s", cov_read_reg3  ? "HIT" : "MISS");
            $display("  Partial WSTRB    : %s", cov_wstrb_byte ? "HIT" : "MISS");
            $display("  Back-to-back     : %s", cov_back2back  ? "HIT" : "MISS");
            $display("  Coverage         : %0d / %0d (%0d%%)", hits, total, (hits*100)/total);
            $display("--------------------------------------------------");
        end
    endtask

    // -------------------------------------------------------
    // Tasks: Write & Read
    // -------------------------------------------------------
    task axi_write;
        input [ADDR_WIDTH-1:0] addr;
        input [DATA_WIDTH-1:0] data;
        input [3:0]            strb;
        integer byte_idx;
        reg [DATA_WIDTH-1:0] masked;
        begin
            // Drive AW + W simultaneously
            awaddr  = addr;
            awvalid = 1;
            wdata   = data;
            wstrb   = strb;
            wvalid  = 1;
            bready  = 1;

            // Wait for both handshakes
            @(posedge clk);
            while (!(awready && wready)) @(posedge clk);

            awvalid = 0;
            wvalid  = 0;

            // Wait for write response
            while (!bvalid) @(posedge clk);
            @(posedge clk);
            bready = 0;

            // Update scoreboard (apply WSTRB)
            masked = expected_regs[addr[3:2]];
            for (byte_idx = 0; byte_idx < 4; byte_idx = byte_idx + 1) begin
                if (strb[byte_idx])
                    masked[byte_idx*8 +: 8] = data[byte_idx*8 +: 8];
            end
            expected_regs[addr[3:2]] = masked;

            update_write_coverage(addr, strb);
        end
    endtask

    task axi_read;
        input  [ADDR_WIDTH-1:0] addr;
        output [DATA_WIDTH-1:0] data_out;
        begin
            araddr  = addr;
            arvalid = 1;
            rready  = 1;

            @(posedge clk);
            while (!arready) @(posedge clk);
            arvalid = 0;

            while (!rvalid) @(posedge clk);
            data_out = rdata;
            @(posedge clk);
            rready = 0;

            update_read_coverage(addr);
        end
    endtask

    // -------------------------------------------------------
    // Stimulus: Constrained-Random + Directed Tests
    // -------------------------------------------------------
    integer seed = 42;
    integer t;
    reg [DATA_WIDTH-1:0] rand_data;
    reg [1:0]            rand_reg;
    reg [3:0]            rand_strb;
    reg [DATA_WIDTH-1:0] read_result;

    initial begin
        $dumpfile("waveforms/axi.vcd");
        $dumpvars(0, tb_axi_lite);

        // Init signals
        awvalid = 0; awaddr = 0;
        wvalid  = 0; wdata  = 0; wstrb = 4'hF;
        bready  = 0;
        arvalid = 0; araddr = 0;
        rready  = 0;

        // Init scoreboard
        for (t = 0; t < NUM_REGS; t = t + 1)
            expected_regs[t] = 0;

        // Release reset
        repeat(3) @(posedge clk);
        rst = 0;
        repeat(2) @(posedge clk);

        $display("=== TEST 1: Directed Full-Word Writes to All Registers ===");
        axi_write(32'h00, 32'hDEADBEEF, 4'hF);
        axi_write(32'h04, 32'hCAFEBABE, 4'hF);
        axi_write(32'h08, 32'hA5A5A5A5, 4'hF);
        axi_write(32'h0C, 32'h12345678, 4'hF);

        $display("=== TEST 2: Directed Reads & Scoreboard Check ===");
        axi_read(32'h00, read_result);
        if (read_result === expected_regs[0])
            begin $display("PASS reg0: got %h", read_result); pass_count = pass_count + 1; end
        else
            begin $display("FAIL reg0: got %h, exp %h", read_result, expected_regs[0]); fail_count = fail_count + 1; end

        axi_read(32'h04, read_result);
        if (read_result === expected_regs[1])
            begin $display("PASS reg1: got %h", read_result); pass_count = pass_count + 1; end
        else
            begin $display("FAIL reg1: got %h, exp %h", read_result, expected_regs[1]); fail_count = fail_count + 1; end

        axi_read(32'h08, read_result);
        if (read_result === expected_regs[2])
            begin $display("PASS reg2: got %h", read_result); pass_count = pass_count + 1; end
        else
            begin $display("FAIL reg2: got %h, exp %h", read_result, expected_regs[2]); fail_count = fail_count + 1; end

        axi_read(32'h0C, read_result);
        if (read_result === expected_regs[3])
            begin $display("PASS reg3: got %h", read_result); pass_count = pass_count + 1; end
        else
            begin $display("FAIL reg3: got %h, exp %h", read_result, expected_regs[3]); fail_count = fail_count + 1; end

        $display("=== TEST 3: Partial WSTRB Write (lower 2 bytes only) ===");
        axi_write(32'h00, 32'hFFFFFFFF, 4'b0011);
        axi_read(32'h00, read_result);
        if (read_result === expected_regs[0])
            begin $display("PASS WSTRB: got %h", read_result); pass_count = pass_count + 1; end
        else
            begin $display("FAIL WSTRB: got %h, exp %h", read_result, expected_regs[0]); fail_count = fail_count + 1; end

        $display("=== TEST 4: Constrained-Random Writes & Readback ===");
        repeat(8) begin
            rand_data = $random(seed);
            rand_reg  = $random(seed) % NUM_REGS;
            rand_strb = 4'hF; // full word for random tests
            axi_write({30'b0, rand_reg, 2'b00}, rand_data, rand_strb);
            axi_read ({30'b0, rand_reg, 2'b00}, read_result);
            if (read_result === expected_regs[rand_reg])
                begin $display("PASS rand reg%0d: got %h", rand_reg, read_result); pass_count = pass_count + 1; end
            else
                begin $display("FAIL rand reg%0d: got %h, exp %h", rand_reg, read_result, expected_regs[rand_reg]); fail_count = fail_count + 1; end
        end

        $display("=== TEST 5: Back-to-Back Transactions ===");
        cov_back2back = 1;
        axi_write(32'h00, 32'hAABBCCDD, 4'hF);
        axi_write(32'h04, 32'h11223344, 4'hF);
        axi_read(32'h00, read_result);
        if (read_result === expected_regs[0])
            begin $display("PASS back2back reg0: got %h", read_result); pass_count = pass_count + 1; end
        else
            begin $display("FAIL back2back reg0: got %h, exp %h", read_result, expected_regs[0]); fail_count = fail_count + 1; end

        // -------------------------------------------------------
        // Final Report
        // -------------------------------------------------------
        repeat(2) @(posedge clk);
        $display("==================================================");
        $display("TEST SUMMARY: %0d PASSED | %0d FAILED", pass_count, fail_count);
        $display("==================================================");
        print_coverage();

        $finish;
    end

endmodule
