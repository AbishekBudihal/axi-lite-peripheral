module axi_lite_slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter NUM_REGS   = 4
)(
    input  wire                  clk,
    input  wire                  rst,

    // ---- WRITE ADDRESS CHANNEL ----
    if (awvalid && !aw_active) begin
        awready     <= 1;
        aw_addr_lat <= awaddr;
        aw_active   <= 1;
    end else begin
        awready <= 0;
    end
    // Write data channel
    input  wire                  wvalid,
    input  wire [DATA_WIDTH-1:0] wdata,
    input  wire [DATA_WIDTH/8-1:0] wstrb,
    output reg                   wready,

    // Write response channel
    output reg                   bvalid,
    output reg  [1:0]            bresp,
    input  wire                  bready,

    // Read address channel
    input  wire                  arvalid,
    input  wire [ADDR_WIDTH-1:0] araddr,
    output reg                   arready,

    // Read data channel
    output reg                   rvalid,
    output reg  [DATA_WIDTH-1:0] rdata,
    output reg  [1:0]            rresp,
    input  wire                  rready
);

    // Register file: 4 x 32-bit registers
    reg [DATA_WIDTH-1:0] regfile [0:NUM_REGS-1];

    // Internal address latches
    reg [ADDR_WIDTH-1:0] aw_addr_lat;
    reg                  aw_active;

    integer i;

    always @(posedge clk) begin
        if (rst) begin
            awready   <= 0;
            wready    <= 0;
            bvalid    <= 0;
            bresp     <= 2'b00;
            arready   <= 0;
            rvalid    <= 0;
            rdata     <= 0;
            rresp     <= 2'b00;
            aw_active <= 0;
            aw_addr_lat <= 0;
            for (i = 0; i < NUM_REGS; i = i + 1)
                regfile[i] <= 0;
        end else begin

            // ---- WRITE ADDRESS CHANNEL ----
            if (awvalid && !awready && !aw_active) begin
                awready     <= 1;
                aw_addr_lat <= awaddr;
                aw_active   <= 1;
            end else begin
                awready <= 0;
            end

            // ---- WRITE DATA CHANNEL ----
            if (wvalid && !wready && aw_active) begin
                wready <= 1;
                // WSTRB: only write bytes where strobe is high
                if (wstrb[0]) regfile[aw_addr_lat[3:2]][7:0]   <= wdata[7:0];
                if (wstrb[1]) regfile[aw_addr_lat[3:2]][15:8]  <= wdata[15:8];
                if (wstrb[2]) regfile[aw_addr_lat[3:2]][23:16] <= wdata[23:16];
                if (wstrb[3]) regfile[aw_addr_lat[3:2]][31:24] <= wdata[31:24];
                bvalid    <= 1;
                bresp     <= 2'b00; // OKAY
                aw_active <= 0;
            end else begin
                wready <= 0;
            end

            // ---- WRITE RESPONSE CHANNEL ----
            if (bvalid && bready) begin
                bvalid <= 0;
            end

            // ---- READ ADDRESS CHANNEL ----
            if (arvalid && !arready && !rvalid) begin
                arready <= 1;
                rdata   <= regfile[araddr[3:2]];
                rresp   <= 2'b00; // OKAY
                rvalid  <= 1;
            end else begin
                arready <= 0;
            end

            // ---- READ DATA CHANNEL ----
            if (rvalid && rready) begin
                rvalid <= 0;
            end

        end
    end

endmodule
