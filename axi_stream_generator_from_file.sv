`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ledoux Louis
// 
// Module Name: axi_stream_generator_from_file
// Description: Generate (push) data with axi stream protocol from a txt file.
//               Aims to help for test bench to test axi stream compliant modules
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_stream_generator_from_file #
(
    parameter WIDTH = 32,
    parameter string base_path = "",
    parameter string path = "",
    parameter integer nb_data = 16,
    parameter READ_B_OR_H = "H"
)
(
    input wire rst_n,
    input wire start,

    input  wire m_axis_clk,
    output logic m_axis_tvalid,
    output logic [WIDTH-1:0] m_axis_tdata,
    output logic [(WIDTH+7/8)-1:0]m_axis_tstrb,
    output logic m_axis_tlast
);  

typedef enum logic [1:0] { IDLE, SEND_STREAM } State;

State sm_state = IDLE;

// Axi Stream internal signals
logic tvalid;
logic tlast;
logic [WIDTH-1:0] tdata;

// init from file data
logic [WIDTH-1:0] file_data [nb_data-1:0];
if (READ_B_OR_H == "H") begin
    initial $readmemh({base_path, path}, file_data);
end
else if (READ_B_OR_H == "B") begin
    initial $readmemb({base_path, path}, file_data);
end
logic [$clog2(nb_data)-1:0] counter;

// state machine
always_ff @(posedge m_axis_clk) begin
    if ( ~rst_n ) begin
        sm_state <= IDLE;
    end
    else begin
        case (sm_state)
            IDLE: begin
                tvalid <= 0;
                tlast  <= 0;
                tdata  <= 0;
                counter <= 0;
                if (start) begin
                    sm_state <= SEND_STREAM;
                end
            end

            SEND_STREAM: begin
                tvalid <= 1;
                tdata  <= file_data[counter];
                if ( start ) begin
                    counter <= counter + 1;
                end
                if ( ~start ) begin
                    tdata <= file_data[counter-1];
                end
                if (counter == nb_data-1) begin
                    tlast <= 1;
                    sm_state <= IDLE;
                end
            end    
            
            default: begin
                sm_state <= IDLE;
            end
        endcase
    end
end

// output
assign m_axis_tdata  = tdata;
assign m_axis_tvalid = tvalid;
assign m_axis_tstrb  = {(WIDTH+7/8){1'b1}};
assign m_axis_tlast  = tlast;

endmodule
