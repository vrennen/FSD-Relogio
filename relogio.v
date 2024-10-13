module dec7seg(
    output reg [6:0] DISPLAY,
    input [3:0] A
);
    always @(*) begin
        case (A)
            4'h0: begin
                DISPLAY <= 7'b1111110;
            end
            4'h1: begin
                DISPLAY <= 7'b0110000;
            end
            4'h2: begin
                DISPLAY <= 7'b1101101;
            end
            4'h3: begin
                DISPLAY <= 7'b1111001;
            end
            4'h4: begin
                DISPLAY <= 7'b0110011;
            end
            4'h5: begin
                DISPLAY <= 7'b1011011;
            end
            4'h6: begin
                DISPLAY <= 7'b1011111;
            end
            4'h7: begin
                DISPLAY <= 7'b1110000;
            end
            4'h8: begin
                DISPLAY <= 7'b1111111;
            end
            4'h9: begin
                DISPLAY <= 7'b1111011;
            end
            4'hA: begin
                DISPLAY <= 7'b1110111;
            end
            4'hB: begin
                DISPLAY <= 7'b0011111;
            end
            4'hC: begin
                DISPLAY <= 7'b1001110;
            end
            4'hD: begin
                DISPLAY <= 7'b0111101;
            end
            4'hE: begin
                DISPLAY <= 7'b1001111;
            end
            4'hF: begin
                DISPLAY <= 7'b1000111;
            end
        endcase
    end
endmodule:dec7seg

module decLEDs(
    output reg[6:0] leds,
    input [6:0] num
);
    always@(*) begin 
        leds = num;
    end
endmodule:decLEDs

module IDmodo(
    output reg[1:0] leds,
    input [1:0] modo
);
    always@(*) begin
        leds = modo;
    end
endmodule:IDmodo

`define rodando 2'b00
`define setMinuto 2'b01
`define setHora 2'b10

module relogio(
    input clk,
    input rst,
    input setState,
    input change,
    output reg [6:0] DISPLAY0,
    output reg [6:0] DISPLAY1,
    output reg [6:0] DISPLAY2,
    output reg [6:0] DISPLAY3,
    output [6:0] LED,
    output reg [1:0] LEDmodo,
    output pontinho
);
    assign pontinho = 1;
    reg [1:0] estado;
    reg [1:0] prox_estado;

    reg [3:0] primeiraEntrada;
    reg [3:0] segundaEntrada;
    reg [3:0] terceiraEntrada;
    reg [3:0] quartaEntrada;
    reg [6:0] seg;

    dec7seg primeiroDigito (DISPLAY0, primeiraEntrada); // xx:xm 
    dec7seg segundoDigito (DISPLAY1, segundaEntrada);   // xx:mx
    dec7seg terceiroDigito (DISPLAY2, terceiraEntrada); // xh:xx
    dec7seg quartoDigito (DISPLAY3, quartaEntrada);     // hx:xx
    decLEDs s0 (LED, seg);
    IDmodo id0 (LEDmodo, estado);

    always@(posedge clk or posedge rst) begin
        if (rst) begin
            estado <= `rodando;
            primeiraEntrada <= 4'h0;
            segundaEntrada <= 4'h0;
            terceiraEntrada <= 4'h0;
            quartaEntrada <= 4'h0;
            seg <= 5'd0;
        end else begin
            if (setState) begin
            estado <= prox_estado;
            end
            case (estado) 
            `rodando: begin seg <= seg + 1'b1;
            if (seg == 59) begin 
                seg <= 0;
                primeiraEntrada <= primeiraEntrada + 1'b1;
            end
            if (primeiraEntrada == 9) begin
                if (seg == 59) begin 
                    primeiraEntrada <= 0;
                    segundaEntrada <= segundaEntrada + 1'b1;
                end
            end
            if (segundaEntrada == 5) begin 
                if (primeiraEntrada == 9) begin 
                    if (seg == 59) begin 
                        segundaEntrada <= 0;
                        terceiraEntrada <= terceiraEntrada + 1'b1;
                    end
                end
            end
            if (terceiraEntrada == 9) begin
                if (segundaEntrada == 5) begin 
                    if (primeiraEntrada == 9) begin 
                        if (seg == 59) begin 
                            terceiraEntrada <= 0;
                            quartaEntrada <= quartaEntrada + 1'b1;
                        end
                    end
                end
            end
            if (quartaEntrada == 2) begin
                if (terceiraEntrada == 3) begin 
                    if (segundaEntrada == 5) begin 
                        if (primeiraEntrada == 9) begin 
                            if (seg == 59) begin 
                                quartaEntrada <= 0;
                                terceiraEntrada <= 0;
                            end
                        end
                    end
                end 
            end
            end

            `setMinuto:

                if (change) begin 
                    primeiraEntrada <= primeiraEntrada + 1'b1;
                    if (primeiraEntrada == 9) begin 
                        primeiraEntrada <= 0;
                        segundaEntrada <= segundaEntrada + 1'b1;
                    end
                    if (segundaEntrada == 5) begin 
                        if (primeiraEntrada == 9) begin 
                            primeiraEntrada <= 0;
                            segundaEntrada <= 0;
                        end
                    end
                end
            `setHora:

                if (change) begin 
                    terceiraEntrada <= terceiraEntrada + 1'b1;
                    if (terceiraEntrada == 9) begin 
                        terceiraEntrada <= 0;
                        quartaEntrada <= quartaEntrada + 1'b1;
                    end
                    if (quartaEntrada == 2) begin 
                        if (terceiraEntrada == 3) begin 
                            quartaEntrada <= 0;
                            terceiraEntrada <= 0;
                        end
                    end
                end
        endcase        
        end
    end
    
    always@(*) begin 
        case (estado)
        `rodando: prox_estado   <= `setMinuto;
        `setMinuto: prox_estado <= `setHora;
        `setHora: prox_estado   <= `rodando;
        default: prox_estado    <= `rodando;
        endcase
    end


endmodule:relogio
