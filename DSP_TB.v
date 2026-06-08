module DSP_tb();

    reg [17:0] A, B, D;
    reg [47:0] C, PCIN;
    reg [17:0] BCIN;
    reg CLK, CARRYIN;
    reg [7:0] OPMODE;
    reg RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE;
    reg CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE;

    wire [47:0] P, PCOUT;
    wire [17:0] BCOUT;
    wire [35:0] M;
    wire CARRYOUT, CARRYOUTF;

    DSP dut (
        .A(A), .B(B), .D(D), .C(C), .PCIN(PCIN), .BCIN(BCIN),
        .CLK(CLK), .CARRYIN(CARRYIN), .OPMODE(OPMODE),
        .RSTA(RSTA), .RSTB(RSTB), .RSTM(RSTM), .RSTP(RSTP), 
        .RSTC(RSTC), .RSTD(RSTD), .RSTCARRYIN(RSTCARRYIN), .RSTOPMODE(RSTOPMODE),
        .CEA(CEA), .CEB(CEB), .CEM(CEM), .CEP(CEP), 
        .CEC(CEC), .CED(CED), .CECARRYIN(CECARRYIN), .CEOPMODE(CEOPMODE),
        .P(P), .PCOUT(PCOUT), .BCOUT(BCOUT), .M(M), 
        .CARRYOUT(CARRYOUT), .CARRYOUTF(CARRYOUTF)
    );

    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end
    
    initial begin
        {A, B, D, C, PCIN, BCIN, CARRYIN, OPMODE} = 0;
        {RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE} = 0;
        {CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE} = 0;

        {RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE} = 8'hFF;
        A = 18'hABC; B = 18'h123;
        repeat (2) @(negedge CLK);

        if (P === 0 && M === 0) 
            $display("RESET SUCCESS");
        else 
            $display("RESET FAILED");

        {RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE} = 8'h00;
        {CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE} = 8'hFF;

        @(negedge CLK);
        A=20; B=10; C=350; D=25; OPMODE = 8'b11011101;
        BCIN = $random; CARRYIN = $random; PCIN = $random;
        repeat(4) @(negedge CLK);

        if (BCOUT == 18'hf && M == 36'h12c && P == 48'h32 && CARRYOUT == 0) 
            $display("PATH 1 SUCCESS!");
        else 
            $display("PATH 1 FAILED!");

        @(negedge CLK);
        A=20; B=10; C=350; D=25; OPMODE = 8'b00010000;
        BCIN = $random; CARRYIN = $random; PCIN = $random;
        repeat(3) @(negedge CLK);

        if (BCOUT == 18'h23 && M == 36'h2bc && P == 48'h0 && CARRYOUT == 0) 
            $display("PATH 2 SUCCESS!");
        else 
            $display("PATH 2 FAILED!");

        @(negedge CLK);
        A=20; B=10; C=350; D=25; OPMODE = 8'b00001010;
        BCIN = $random; CARRYIN = $random; PCIN = $random;
        repeat(3) @(negedge CLK);

        if (BCOUT == 18'ha && M == 36'hc8) 
            $display("PATH 3 SUCCESS!");
        else 
            $display("PATH 3 FAILED!");

        @(negedge CLK);
        A = 5; B = 6; C = 350; D = 25; PCIN = 3000;
        OPMODE = 8'b10100111; 
        BCIN = $random; CARRYIN = $random;

        repeat (3) @(negedge CLK);
        
        if (BCOUT == 18'h6 && M == 36'h1e && P == 48'hfe6fffec0bb1 && CARRYOUT == 1) 
            $display("PATH 4 SUCCESS!");
        else 
            $display("PATH 4 FAILED!");
        
        $stop;
    end

endmodule