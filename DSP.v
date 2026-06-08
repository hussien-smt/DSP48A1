module DSP #(
    parameter A0REG = 0, A1REG = 1, B0REG = 0, B1REG = 1,
    parameter CREG = 1, DREG = 1, MREG = 1, PREG = 1,
    parameter CARRYINREG = 1, CARRYOUTREG = 1, OPMODEREG = 1,
    parameter CARRYINSEL = "OPMODE5", 
    parameter B_INPUT = "DIRECT",     
    parameter RSTTYPE = "SYNC"        
)(
    
    input [17:0] A, B, D, 
    input [47:0] C,
    input [47:0] PCIN,
    input [17:0] BCIN,
    
    input CLK, 
    input [7:0] OPMODE,
    input CARRYIN,
   
    input RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE,
  
    input CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE,
   
    output [47:0] P, PCOUT,
    output [17:0] BCOUT,
    output [35:0] M,
    output CARRYOUT, CARRYOUTF
);
    reg [17:0] a0_reg, a1_reg, b0_reg, b1_reg, d_reg;
    reg [47:0] c_reg, p_reg;
    reg [35:0] m_reg;
    reg [7:0] opmode_reg;
    reg cyi_reg, cyo_reg;
    reg [47:0] x_mux, z_mux;

    wire [17:0] a0_mux, a1_mux, b0_mux, b1_mux, d_mux;
    wire [47:0] c_mux, p_mux;
    wire [35:0] m_mux;
    wire [7:0] opmode_mux;
    wire cyi_mux, cyo_mux;

    wire async_rst = (RSTTYPE == "ASYNC");


    always @(posedge CLK or posedge RSTA) begin
        if (RSTA) a0_reg <= 18'b0;
        else if (CEA) a0_reg <= A;
    end

    assign a0_mux = (A0REG) ? a0_reg : A;
   
    wire [17:0] b_input_val = (B_INPUT == "CASCADE") ? BCIN : B;
    always @(posedge CLK or posedge RSTB) begin
        if (RSTB) b0_reg <= 18'b0;
        else if (CEB) b0_reg <= b_input_val;
    end
    assign b0_mux = (B0REG) ? b0_reg : b_input_val;

   
    always @(posedge CLK or posedge RSTD) begin
        if (RSTD) d_reg <= 18'b0;
        else if (CED) d_reg <= D;
    end
    assign d_mux = (DREG) ? d_reg : D;
   wire [17:0] pre_adder_out = (opmode_mux[6]) ? (d_mux - b0_mux) : (d_mux + b0_mux);
    wire [17:0] post_pre_adder_mux = (opmode_mux[4]) ? pre_adder_out : b0_mux;
 

     always @(posedge CLK or posedge RSTA) begin
        if (RSTA) a1_reg <= 18'b0;
        else if (CEA) a1_reg <= a0_mux;
    end
    assign a1_mux = (A1REG) ? a1_reg : a0_mux;
    
  
    always @(posedge CLK or posedge RSTB) begin
        if (RSTB) b1_reg <= 18'b0;
        else if (CEB) b1_reg <= post_pre_adder_mux;
    end
    assign b1_mux = (B1REG) ? b1_reg : post_pre_adder_mux;
    assign BCOUT = b1_mux;

    wire [35:0] multiplier_out = a1_mux * b1_mux;
    always @(posedge CLK or posedge RSTM) begin
        if (RSTM) m_reg <= 36'b0;
        else if (CEM) m_reg <= multiplier_out;
    end
    assign m_mux = (MREG) ? m_reg : multiplier_out;
    assign M = m_mux;

    always @(posedge CLK or posedge RSTOPMODE) begin
        if (RSTOPMODE) opmode_reg <= 8'b0;
        else if (CEOPMODE) opmode_reg <= OPMODE;
    end
    assign opmode_mux = (OPMODEREG) ? opmode_reg : OPMODE;

    always @(posedge CLK or posedge RSTC) begin
        if (RSTC) c_reg <= 48'b0;
        else if (CEC) c_reg <= C;
    end
    assign c_mux = (CREG) ? c_reg : C;


    wire [47:0] DAB_concat = {d_mux[11:0], a1_mux[17:0], b1_mux[17:0]}; 

  
always @(*) begin
    case (opmode_mux[1:0])
        2'b01:   x_mux = {12'b0, m_mux}; 
        2'b10:   x_mux = p_mux;          
        2'b11:   x_mux = DAB_concat;     
        default: x_mux = 48'b0;          
    endcase
end

always @(*) begin
    case (opmode_mux[3:2])
        2'b01:   z_mux = PCIN;                        
        2'b10:   z_mux = p_mux;                          
        2'b11:   z_mux = c_mux;                          
        default: z_mux = 48'b0;                          
    endcase
end
   
    wire cin_wire = (CARRYINSEL == "OPMODE5") ? opmode_mux[5] : CARRYIN; 
    always @(posedge CLK or posedge RSTCARRYIN) begin
        if (RSTCARRYIN) cyi_reg <= 1'b0;
        else if (CECARRYIN) cyi_reg <= cin_wire;
    end
    assign cyi_mux = (CARRYINREG) ? cyi_reg : cin_wire;

    wire [48:0] post_adder_out = (opmode_mux[7]) ? (z_mux - (x_mux + cyi_mux)) : (z_mux + x_mux + cyi_mux);



    always @(posedge CLK or posedge RSTP) begin
        if (RSTP) p_reg <= 48'b0;
        else if (CEP) p_reg <= post_adder_out[47:0];
    end

    assign p_mux = (PREG) ? p_reg : post_adder_out[47:0];
    assign P = p_mux;
    assign PCOUT = p_mux;
    always @(posedge CLK or posedge RSTCARRYIN) begin
        if (RSTCARRYIN) cyo_reg <= 1'b0;
        else if (CECARRYIN) cyo_reg <= post_adder_out[48];
    end
    assign cyo_mux = (CARRYOUTREG) ? cyo_reg : post_adder_out[48];
    assign CARRYOUT = cyo_mux;
    assign CARRYOUTF = cyo_mux;
endmodule