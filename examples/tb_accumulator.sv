////////////////////////////////////////////////////////////////////////////////
// 
// Company: BSC
// Author: SomeOne
//
// Create Date: 14/04/2019
// Module Name: tb_accumulator
// Description:
//     A very short useless description
//
////////////////////////////////////////////////////////////////////////////////

module tb_accumulator();

    parameter CLK_PERIOD      = 2;
    parameter CLK_HALF_PERIOD = CLK_PERIOD / 2;
    
    localparam integer DATA_WIDTH = 8;
    localparam integer NB_DATA = 10;
    localparam  INPUT_BASE_PATH = "";
    localparam  INPUT_PATH = "";
    localparam  READ_B_OR_H = "H";
    
    //----------------------------------------------------------------
    // Signals, clocks, and reset
    //----------------------------------------------------------------

    logic tb_clk;
    logic tb_reset_n;

    // file (picture) read
    logic s_axis_in_aclk;
    logic s_axis_in_tready;
    logic s_axis_in_aresetn;
    logic s_axis_in_tvalid;
    logic [DATA_WIDTH-1:0] s_axis_in_tdata;
    logic [(DATA_WIDTH/8)-1:0] s_axis_in_tstrb;
    logic s_axis_in_tlast;
    logic sow_i;

    // output
    logic rts_o;
    logic eow_o;
    logic sow_o;

    axi_stream_generator_from_file #
    (
        .WIDTH       ( DATA_WIDTH           ),
        .base_path   ( INPUT_BASE_PATH      ),
        .path        ( INPUT_PATH           ),
        .nb_data     ( NB_DATA              ),
        .READ_B_OR_H ( READ_B_OR_H          )
    )
    axi_stream_generator_inst 
    (

       .rst_n         ( tb_reset_n       ),
       // Starts an axi_stream transaction
       .start         ( s_axis_in_tready ),

       // axi stream ports
       .m_axis_clk    ( tb_clk           ),
       .m_axis_tvalid ( s_axis_in_tvalid ),
       .m_axis_tdata  ( s_axis_in_tdata  ),
       .m_axis_tstrb  ( s_axis_in_tstrb  ),
       .m_axis_tlast  ( s_axis_in_tlast  )
    );

    // logic for sow
    logic s_axis_in_tvalid_r;
    always_ff @(posedge tb_clk or negedge tb_reset_n) begin
        if ( ~tb_reset_n ) begin
            s_axis_in_tvalid_r <= 0;
        end
        else begin
            s_axis_in_tvalid_r <= s_axis_in_tvalid;
        end
    end
    assign sow_i   = s_axis_in_tvalid & ~s_axis_in_tvalid_r;


    // INSTANCIATE DUT



    //----------------------------------------------------------------
    // clk_gen
    //
    // Always running clock generator process.
    //----------------------------------------------------------------

    initial tb_clk = 0;
    always #CLK_HALF_PERIOD tb_clk = !tb_clk;

    //----------------------------------------------------------------
    // reset_dut()
    //
    // Toggle reset to put the DUT into a well known state.
    //----------------------------------------------------------------
    task reset_dut;
        begin
            $display("*** Toggle reset.");
            tb_reset_n = 0;
            #(100 * CLK_PERIOD);
            tb_reset_n = 1;
        end
    endtask // reset_dut

    //----------------------------------------------------------------
    // init_sim()
    //
    // All the init part
    //----------------------------------------------------------------
    task init_sim;
        begin
            $display("*** init sim.");
            tb_clk = 0;
            tb_reset_n = 1;
        end
    endtask // reset_dut

    //----------------------------------------------------------------
    // init sim
    //----------------------------------------------------------------
    initial begin

        assign s_axis_in_aclk    = tb_clk;
        assign s_axis_in_aresetn = tb_reset_n;

        init_sim();
        reset_dut();
    end

endmodule
