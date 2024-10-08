module controle(
    input reset, clock, bi1, bi2, bi3, bi4, bi5, be1, be2, be3, be4, be5, s1, s2, s3, s4, s5,
    output int saida, estado_motor,
  output logic Port1, Port2, Port3, Port4, Port5, output logic [3:0] pavimento
);

	enum logic [4:0] {
		p1,
		p2, 
		p3, 
		p4, 
		p5
	} estado;

	enum logic [4:0] {
		desativar_motor, 
		pa, 
		count_down, 
		pf, 
		d_botoes
	} elev_parado;

	// 0 = parado, 1 = subindo, -1 = descendo | Serve para armazenar o estado do motor, antes dele parar e priorizar este valor ao voltar a funcionar.
	int cont;
	
	logic
		i1, i2, i3, i4, i5, 
		e1, e2, e3, e4, e5, 
		sp1, sp2, sp3, sp4, sp5;
  	
  	assign pavimento = estado;
  
  // Aproveitem a estrutura do código da janela
    
  always @ (posedge reset or posedge clock) begin
    if (reset == 1) begin
			elev_parado <= desativar_motor;
			saida <= 0;      // Motor parado
			estado_motor <= 0; // Estado do motor (parado)
      		cont  <= 0;
			Port1 <= 0;
			Port2 <= 0;
			Port3 <= 0;
      		Port4 <= 0;
         	Port5 <= 0;
      		sp1 <= 1;
			sp2 <= 1;
			sp3 <= 1;
			sp4 <= 1;
			sp5 <= 1;
				
    end else begin
        case (estado)
            p1: begin // Estado: andar 1
              if ((e1 || i1) && s1) begin // se um dos bostões do andar 1 estejam pressionados e o andar atual do elevador seja 1
                case (elev_parado) //inicia o case da submáquina que para o elevador
                  desativar_motor: begin // inicia o estado de desativar o motor
                    saida = 0; // motor irá para 0
                    if (saida == 0) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = pa; // se atendido, submáquina irá para o próximo estado
                    end 
                    else begin // se não...
                      elev_parado = desativar_motor; // ...estado da submáquina será mantido o mesmo
                    end
                     
                  end

                  pa: begin // inicia o estado de abrir a porta
                    Port1 = 1; // abre a porta 1
                    if (Port1 == 1) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = count_down; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = pa; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  count_down: begin // inicia o estado de aguardar 
                    $display("Contando = %d,    time=%0d", cont + 1, $time);
                    cont = cont + 1; // incrementa o contador
                    if (cont == 5000000) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      cont = 0; // zera o contador antes de ir para o próximo estado para que possa ser usado novamente futuramente
                      elev_parado = pf; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = count_down; // ...estado da submáquina será mantido o mesmo
                    end
                  end
                  
                  pf: begin
                    Port1 = 0; // fecha a porta do andar 1
                    if(Port1 == 0) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                    	elev_parado = d_botoes; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = pf; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  d_botoes: begin // inicia o estado de desativar os botões
                    sp1 = 0; // ativa a variável, para sinalizar, assim, que os botões do andar 1 devem ser desativados
                  end

                endcase
              
                
              end else if (elev_parado == d_botoes) begin
                elev_parado = desativar_motor; // leva a submáquina para seu primeiro estado, para que ela possa ser usada futuramente
                sp1 = 1; // Desativa a variável para zerar botões, para que possa ser usada futuramente

              end else if (e2 || i2 || e3 || i3 || e4 || i4 || e5 || i5) begin
                saida = 1;   // Motor subindo
                estado_motor = 1;

              end else begin
                saida = 0;   // Motor parado
                estado_motor = 0;
              end
            end
            
            p2: begin // Estado: andar 2
              if ((e2 || i2) && s2) begin // se um dos bostões do andar 2 estejam pressionados e o andar atual do elevador seja 2
                case(elev_parado)
                  desativar_motor: begin // inicia o estado de desativar o motor
                    saida = 0; // motor irá para 0
                    if (saida == 0) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = pa; // se atendido, submáquina irá para o próximo estado
                    end 
                    else begin // se não...
                      elev_parado = desativar_motor; // ...estado da submáquina será mantido o mesmo
                    end
                     
                  end

                  pa: begin // inicia o estado de abrir a porta
                    Port2 = 1; // abre a porta 2
                    if (Port2 == 1) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = count_down; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = pa; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  count_down: begin // inicia o estado de aguardar 
                    $display("Contando = %d,    time=%0d", cont + 1, $time);
                    cont = cont + 1; // incrementa o contador
                    if (cont == 5000000) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      cont = 0; // zera o contador antes de ir para o próximo estado para que possa ser usado novamente futuramente
                      elev_parado = pf; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = count_down; // ...estado da submáquina será mantido o mesmo
                    end
                  end
                  
                  pf: begin
                    Port2 = 0; // fecha a porta do andar 2
                    if(Port2 == 0) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                    	elev_parado = d_botoes; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = pf; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  d_botoes: begin // inicia o estado de desativar os botões
                    sp2 = 0; // ativa a variável, para sinalizar, assim, que os botões do andar 2 devem ser desativados
                  end

                endcase
              
                
              end else if (elev_parado == d_botoes) begin
                elev_parado = desativar_motor; // leva a submáquina para seu primeiro estado, para que ela possa ser usada futuramente
                sp2 = 1; // Desativa a variável para zerar botões, para que possa ser usada futuramente
              end else begin
                case (estado_motor)
                  1:begin
                    if(e3 || i3 || e4 || i4 || e5 || i5) begin
                      saida = 1;
                      estado_motor = 1;
                    end 
                    else if(e1 || i1) begin
                      saida = -1;
                      estado_motor = -1;
                    end
                    else begin
                      saida = 0;
                      estado_motor = 0;
                    end
                  end
                  
                  -1:begin
                    if(e1 || i1) begin
                      saida = -1;
                      estado_motor = -1;
                    end 
                    else if(e3 || i3 || e4 || i4 || e5 || i5) begin
                      saida = 1;
                      estado_motor = 1;
                    end
                    else begin
                      saida = 0;
                      estado_motor = 0;
                    end
                  end
                  
                  0:begin
                    if(e3 || i3 || e4 || i4 || e5 || i5) begin
                      saida = 1;
                      estado_motor = 1;
                    end 
                    else if(e1 || i1) begin
                      saida = -1;
                      estado_motor = -1;
                    end
                    else begin
                      saida = 0;
                      estado_motor = 0;
                    end
                  end
                
                endcase
              
              end
            end
          	
          	p3: begin // Estado: andar 3
              if ((e3 || i3) && s3) begin // se um dos bostões do andar 3 estejam pressionados e o andar atual do elevador seja 
                case (elev_parado) //inicia o case da submáquina que para o elevador
                  desativar_motor: begin // inicia o estado de desativar o motor
                    estado_motor = saida;
                    saida = 0; // motor irá para 0
                    if (saida == 0) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = pa; // se atendido, submáquina irá para o próximo estado
                    end 
                    else begin // se não...
                      elev_parado = desativar_motor; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  pa: begin // inicia o estado de abrir a porta
                    Port3 = 1; // abre a porta 3
                    if (Port3 == 1) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = count_down; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = pa; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  count_down: begin // inicia o estado de aguardar 
                    $display("Contando = %d,    time=%0d", cont + 1, $time);
                    cont = cont + 1; // incrementa o contador
                    if (cont == 5000000) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      cont = 0; // zera o contador antes de ir para o próximo estado para que possa ser usado novamente futuramente
                      elev_parado = pf; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = count_down; // ...estado da submáquina será mantido o mesmo
                    end
                  end
                  
                  pf: begin
                    Port3 = 0; // fecha a porta do andar 3
                    if(Port3 == 0) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                    	elev_parado = d_botoes; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = pf; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  d_botoes: begin // inicia o estado de desativar os botões
                    sp3 = 0; // ativa a variável, para sinalizar, assim, que os botões do andar 3 devem ser desativados
                  end

                endcase
              
                
              end else if (elev_parado == d_botoes) begin
                elev_parado = desativar_motor; // leva a submáquina para seu primeiro estado, para que ela possa ser usada futuramente
                 sp3 = 1; // Desativa a variável para zerar botões, para que possa ser usada futuramente
              end else begin
                case (estado_motor)
                  1:begin
                    if(e4 || i4 || e5 || i5) begin
                      saida = 1;
                      estado_motor = 1;
                    end 
                    else if(e1 || i1 || e2 || i2) begin
                      saida = -1;
                      estado_motor = -1;
                    end
                    else begin
                      saida = 0;
                      estado_motor = 0;
                    end
                  end
                  
                  -1:begin
                    if(e1 || i1 || e2 || i2) begin
                      saida = -1;
                      estado_motor = -1;
                    end 
                    else if(e4 || i4 || e5 || i5) begin
                      saida = 1;
                      estado_motor = 1;
                    end
                    else begin
                      saida = 0;
                      estado_motor = 0;
                    end
                  end
                  
                  0:begin
                    if(e4 || i4 || e5 || i5) begin
                      saida = 1;
                      estado_motor = 1;
                    end 
                    else if(e1 || i1 || e2 || i2) begin
                      saida = -1;
                      estado_motor = -1;
                    end
                    else begin
                      saida = 0;
                      estado_motor = 0;
                    end
                  end
                
                endcase
              
              end
            end
          	
          	p4: begin // Estado: andar 4
              if ((e4 || i4) && s4) begin // se um dos bostões do andar 4 estejam pressionados e o andar atual do elevador seja 
                case (elev_parado) //inicia o case da submáquina que para o elevador
                  desativar_motor: begin // inicia o estado de desativar o motor
                    saida = 0; // motor irá para 0
                    if (saida == 0) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = pa; // se atendido, submáquina irá para o próximo estado
                    end 
                    else begin // se não...
                      elev_parado = desativar_motor; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  pa: begin // inicia o estado de abrir a porta
                    Port4 = 1; // abre a porta 4
                    if (Port4 == 1) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = count_down; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = pa; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  count_down: begin // inicia o estado de aguardar 
                    $display("Contando = %d,    time=%0d", cont + 1, $time);
                    cont = cont + 1; // incrementa o contador
                    if (cont == 5000000) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      cont = 0; // zera o contador antes de ir para o próximo estado para que possa ser usado novamente futuramente
                      elev_parado = pf; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = count_down; // ...estado da submáquina será mantido o mesmo
                    end
                  end
                  
                  pf: begin
                    Port4 = 0; // fecha a porta do andar 4
                    if(Port4 == 0) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                    	elev_parado = d_botoes; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = pf; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  d_botoes: begin // inicia o estado de desativar os botões
                    sp4 = 0; // ativa a variável, para sinalizar, assim, que os botões do andar 4 devem ser desativados
                  end

                endcase
              
                
              end else if (elev_parado == d_botoes) begin
                elev_parado = desativar_motor; // leva a submáquina para seu primeiro estado, para que ela possa ser usada futuramente
                 sp4 = 1; // Desativa a variável para zerar botões, para que possa ser usada futuramente
              end else begin
                case (estado_motor)
                  1:begin
                    if(e5 || i5) begin
                      saida = 1;
                      estado_motor = 1;
                    end 
                    else if(e1 || i1 || e2 || i2 || e3 || i3) begin
                      saida = -1;
                      estado_motor = -1;
                    end
                    else begin
                      saida = 0;
                      estado_motor = 0;
                    end
                  end
                  
                  -1:begin
                    if(e1 || i1 || e2 || i2 || e3 || i3) begin
                      saida = -1;
                      estado_motor = -1;
                    end 
                    else if(e5 || i5) begin
                      saida = 1;
                      estado_motor = 1;
                    end
                    else begin
                      saida = 0;
                      estado_motor = 0;
                    end
                  end
                  
                  0:begin
                    if(e5 || i5) begin
                      saida = 1;
                      estado_motor = 1;
                    end 
                    else if(e1 || i1 || e2 || i2 || e3 || i3) begin
                      saida = -1;
                      estado_motor = -1;
                    end
                    else begin
                      saida = 0;
                      estado_motor = 0;
                    end
                  end
                
                endcase
              
              end
            end
          
          	p5: begin // Estado: andar 5
              if ((e5 || i5) && s5) begin // se um dos bostões do andar 5 estejam pressionados e o andar atual do elevador seja 
                case (elev_parado) //inicia o case da submáquina que para o elevador
                  desativar_motor: begin // inicia o estado de desativar o motor
                    saida = 0; // motor irá para 0
                    if (saida == 0) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = pa; // se atendido, submáquina irá para o próximo estado
                    end 
                    else begin // se não...
                      elev_parado = desativar_motor; // ...estado da submáquina será mantido o mesmo
                    end
                  end
                  pa: begin // inicia o estado de abrir a porta
                    Port5 = 1; // abre a porta 5
                    if (Port5 == 1) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = count_down; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = pa; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  count_down: begin // inicia o estado de aguardar 
                    $display("Contando = %d,    time=%0d", cont + 1, $time);
                    cont = cont + 1; // incrementa o contador
                    if (cont == 5000000) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      cont = 0; // zera o contador antes de ir para o próximo estado para que possa ser usado novamente futuramente
                      elev_parado = pf; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = count_down; // ...estado da submáquina será mantido o mesmo
                    end
                  end
                  
                  pf: begin
                    Port5 = 0; // fecha a porta do andar 5
                    if(Port5 == 0) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                    	elev_parado = d_botoes; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = pf; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  d_botoes: begin // inicia o estado de desativar os botões
                    sp5 = 0; // ativa a variável, para sinalizar, assim, que os botões do andar 5 devem ser desativados
                  end

                endcase
              
                
              end else if (elev_parado == d_botoes) begin
                elev_parado = desativar_motor; // leva a submáquina para seu primeiro estado, para que ela possa ser usada futuramente
                 sp5 = 1; // Desativa a variável para zerar botões, para que possa ser usada futuramente
              end else if (e1 || i1 || e2 || i2 || e3 || i3 || e4 || i4) begin
                saida = -1;   // Motor subindo
                estado_motor = -1;
              end else begin
                saida = 0;   // Motor parado
                estado_motor = 0;
              end
            end
            
            default: begin
                estado <= p1; // Estado padrão é o andar 1
            end
        endcase
    end
   end
  
  // Always externos para que sempre que um botão seja pressionado, ative as variáveis de armazenamento. Também servem para desativar as variáveis de armazenamento, sempre que o elevador terminar as transições da sub-máquina para abrir a porta
  
      always @(posedge be1 or negedge sp1) begin
        if(!sp1) e1 <= 0;
        else if(be1) e1 <= 1;
        else e1 <= be1;
    end

    always @(posedge bi1 or negedge sp1)begin
        if(!sp1) i1 <= 0;
        else if(bi1) i1 <= 1;
        else i1 <= bi1;
    end

    always @(posedge be2 or negedge sp2) begin
        if(!sp2) e2 <= 0;
        else if(be2) e2 <= 1;
        else e2 <= be2;
    end

    always @(posedge bi2 or negedge sp2)begin
        if(!sp2) i2 <= 0;
        else if(bi2) i2 <= 1;
        else i2 <= bi2;
    end

    always @(posedge be3 or negedge sp3) begin
        if(!sp3) e3 <= 0;
        else if(be3) e3 <= 1;
        else e3 <= be3;
    end

    always @(posedge bi3 or negedge sp3)begin
        if(!sp3) i3 <= 0;
        else if(bi3) i3 <= 1;
        else i3 <= bi3;
    end

    always @(posedge be4 or negedge sp4) begin
        if(!sp4) e4 <= 0;
        else if(be4) e4 <= 1;
        else e4 <= be4;
    end

    always @(posedge bi4 or negedge sp4)begin
        if(!sp4) i4 <= 0;
        else if(bi4) i4 <= 1;
        else i4 <= bi4;
    end

    always @(posedge be5 or negedge sp5) begin
        if(!sp5) e5 <= 0;
        else if(be5) e5 <= 1;
        else e5 <= be5;
    end

    always @(posedge bi5 or negedge sp5)begin
        if(!sp5) i5 <= 0;
        else if(bi5) i5 <= 1;
        else i5 <= bi5;
    end
  
    always @(posedge clock or posedge reset) begin
      if(reset) estado <= p1;
      else if(s1) estado <= p1;
      else if(s2) estado <= p2;
      else if(s3) estado <= p3;
      else if(s4) estado <= p4;
      else if(s5) estado <= p5;
    end
    
   
endmodule

// Divisor de frequencia de 50MHz para 1MHz

module divfreq(input reset, clock, output logic clk_i);
    
int contador;
  
  always @(posedge clock or posedge reset) begin
    if(reset) begin
      contador  = 0;
      clk_i = 0;
    end
    else
      if( contador <= 25 )
        contador = contador + 1;
      else begin
        clk_i = ~clk_i;
        contador = 0;
      end
  end
endmodule

module BCDto7SEGMENT( input logic[3:0] bcd, output logic [6:0] Seg );

 
always begin

	 case(bcd+1) 
		   4'b0000 : Seg = 7'b1000000;
			4'b0001 : Seg = 7'b1111001;
			4'b0010 : Seg = 7'b0100100;
			4'b0011 : Seg = 7'b0110000;
			4'b0100 : Seg = 7'b0011001;
			4'b0101 : Seg = 7'b0010010;
			4'b0110 : Seg = 7'b0000010;
			4'b0111 : Seg = 7'b1111000;
			4'b1000 : Seg = 7'b0000000;
			4'b1001 : Seg = 7'b0011000;      
         4'b1010 : Seg = 7'b0001000;
			4'b1011 : Seg = 7'b0000011;
			4'b1100 : Seg = 7'b1000110;
			4'b1101 : Seg = 7'b0100001;
			4'b1110 : Seg = 7'b0000110;		
			4'b1111 : Seg = 7'b0001110;
	 
	 endcase
 
 end

 
endmodule



module conv_saida( input int entrada, output logic [2:0] saida );
always begin

	 case(entrada)
	 
		  0: saida = 3'b010;
		  1: saida = 3'b100;
		 -1: saida = 3'b001;
		 
		 default: saida = 3'b010;
	 
	 endcase
 
 end

 
endmodule
