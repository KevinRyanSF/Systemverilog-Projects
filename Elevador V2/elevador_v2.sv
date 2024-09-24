 /*
 =====================================================================================================================
 
 CONTROLADORA PARA DOIS ELEVADORES
 
	Módulos utilizados:
		Elevador - Linha 51;       						Sistema que gerencia as chamadas internas, função NoStop e alerta do elevador
		Controladora - Linha: 912; 						Sistema que gerencia as chamadas externas para dois elevadores, decidindo o melhor 
		Divisor de frequência - Linha: 840; 			Utilizado para deixar o Clock mais lento e ser possível simular o sistema em uma FPGA 
		Sequenciador de pavimentos - Linha: 1775;  	Utilizado para simular as transições de pavimentos dos elevadores
		
	
	Todos os parametros utilizados nos módulos estão no início de cada um. Caso deseje mudar algum, pode utilziar da legenda para alterá-los.
	
	LEGENDA DE PARAMETROS:
	
		ELEVADOR:
			time_porta - Linha: 67; 		Utilizado para determinar quantos pulsos de clock a porta ficará aberta;
			
		CONTROLADORA:
			num_call - Linha: 930;  		Utilizado para definir quantas chamadas externas existirão, deve ser calculado por: ((Número de andares - 1) * 2)
			MAX_INT - Linha: 931; 			Utilizado para criar um máximo inteiro possível, ajudando a decidir qual elevador mais eficiente (NÃO DEVE SER MUDADO)
			
		DIVISOR DE FREQUENCIA:
			num_clock - Linha: 842; 		Utilizado para determinar quantas vezes o clock original deve ser ativo para que seja gerado um clock dividido
			
		SEQUENCIADOR DE PAVIMENTOS:
			time_p - Linha: 1779; 			Tempo que o elevador ficará no pavimento
			time_s - Linha: 1782; 			Tempo que o elevador ficará com o sinal abaixado
			
 
 
 =====================================================================================================================
 */
 
 
 package my_functions; // pacote contendo as funções que criamos para que possam ser usadas em todos os módulos

	 
	function int abs(int value); // função para determinar o módulo de um inteiro;
		if (value < 0) begin
			return -value;
		end else begin
			return value;
		end
	endfunction

endpackage


module elevador (	input     					reset, 
												clock,
												noStopIn,
												bi1, bi2, bi3, bi4, bi5, 
												be1, be2, be3, be4, be5, 
												s1, s2, s3, s4, s5, 
					output logic [1:0]	motor, 
					output logic [1:0]   sentidoMotor,
					output logic 			port1, port2, port3, port4, port5,
					output logic			l1, l2, l3, l4, l5,
					output logic [6:0] 	displayInterno,
					output logic			alerta,
					output logic 			noStopOut
);
	import my_functions::*; // importando todo o pacote de funções

	parameter time_porta = 50;
	
	enum logic [3:0] {
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

	// 00 = parado, 01 = subindo, 10 = descendo | Serve para armazenar o estado do motor, antes dele parar e priorizar este valor ao voltar a funcionar.
	int cont; // serve para contar o tempo de porta aberta.
	int cont_led = 0;
	
	logic
		i1, i2, i3, i4, i5, 
		e1, e2, e3, e4, e5, 
		sp1, sp2, sp3, sp4, sp5,
		alerta_leds;
	
  	
  
  // Aproveitem a estrutura do código da janela
    
	always @ (posedge reset or posedge clock) begin
    if (reset == 1) begin
			elev_parado <= desativar_motor;
			motor <= 2'b10;      // Motor parado
			sentidoMotor <= 2'b10; // Estado do motor (parado)
      	cont  <= 0;
			port1 <= 0;
			port2 <= 0;
			port3 <= 0;
      	port4 <= 0;
         port5 <= 0;
      	sp1 <= 1;
			sp2 <= 1;
			sp3 <= 1;
			sp4 <= 1;
			sp5 <= 1;
				
    end else begin
		if (alerta == 0) begin // if para só rodar a máquina se o alerta estiver desligado.
		
        case (estado)
            p1: begin // Estado: andar 1
              if ((e1 || i1) && s1) begin // se um dos bostões do andar 1 estejam pressionados e o andar atual do elevador seja 1
                case (elev_parado) //inicia o case da submáquina que para o elevador
                  desativar_motor: begin // inicia o estado de desativar o motor
                    motor = 2'b00; // motor irá para 0
                    if (motor == 2'b00) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = pa; // se atendido, submáquina irá para o próximo estado
                    end 
                    else begin // se não...
                      elev_parado = desativar_motor; // ...estado da submáquina será mantido o mesmo
                    end
                     
                  end

                  pa: begin // inicia o estado de abrir a porta
                    port1 = 1; // abre a porta 1
                    if (port1 == 1) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = count_down; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = pa; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  count_down: begin // inicia o estado de aguardar 
                    $display("Contando = %d,    time=%0d", cont + 1, $time);
                    cont = cont + 1; // incrementa o contador
                    if (cont == time_porta) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      cont = 0; // zera o contador antes de ir para o próximo estado para que possa ser usado novamente futuramente
                      elev_parado = pf; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = count_down; // ...estado da submáquina será mantido o mesmo
                    end
                  end
                  
                  pf: begin
                    port1 = 0; // fecha a porta do andar 1
                    if(port1 == 0) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
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
                motor = 2'b01;   // Motor subindo
                sentidoMotor = 2'b01;

              end else begin
                motor = 2'b00;   // Motor parado
                sentidoMotor = 2'b00;
              end
            end
            
            p2: begin // Estado: andar 2
              if ((e2 || i2) && s2) begin // se um dos bostões do andar 2 estejam pressionados e o andar atual do elevador seja 2
                case(elev_parado)
                  desativar_motor: begin // inicia o estado de desativar o motor
                    sentidoMotor = motor;
                    motor = 2'b00; // motor irá para 0
                    if (motor == 2'b00) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = pa; // se atendido, submáquina irá para o próximo estado
                    end 
                    else begin // se não...
                      elev_parado = desativar_motor; // ...estado da submáquina será mantido o mesmo
                    end
                     
                  end

                  pa: begin // inicia o estado de abrir a porta
                    port2 = 1; // abre a porta 2
                    if (port2 == 1) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = count_down; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = pa; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  count_down: begin // inicia o estado de aguardar 
                    $display("Contando = %d,    time=%0d", cont + 1, $time);
                    cont = cont + 1; // incrementa o contador
                    if (cont == time_porta) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      cont = 0; // zera o contador antes de ir para o próximo estado para que possa ser usado novamente futuramente
                      elev_parado = pf; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = count_down; // ...estado da submáquina será mantido o mesmo
                    end
                  end
                  
                  pf: begin
                    port2 = 0; // fecha a porta do andar 2
                    if(port2 == 0) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
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
                case (sentidoMotor)
                  2'b01:begin
                    if(e3 || i3 || e4 || i4 || e5 || i5) begin
							$display("entrou no if de subida - subida");
                      motor = 2'b01;
                      sentidoMotor = 2'b01;
                    end 
                    else if(e1 || i1) begin
                      motor = 2'b10;
                      sentidoMotor = 2'b10;
                    end
                    else begin
                      motor = 2'b00;
                      sentidoMotor = 2'b00;
                    end
                  end
                  
                  2'b10:begin
                    if(e1 || i1) begin
                      motor = 2'b10;
                      sentidoMotor = 2'b10;
                    end 
                    else if(e3 || i3 || e4 || i4 || e5 || i5) begin
							 $display("entrou no if de descida - subida");
                      motor = 2'b01;
                      sentidoMotor = 2'b01;
                    end
                    else begin
                      motor = 2'b00;
                      sentidoMotor = 2'b00;
                    end
                  end
                  
                  2'b00:begin
                    if(e3 || i3 || e4 || i4 || e5 || i5) begin
							$display("entrou no if de parada - subida");
                      motor = 2'b01;
                      sentidoMotor = 2'b01;
							$display("motor: %0b, sentido: %0b", motor, sentidoMotor);
                    end 
                    else if(e1 || i1) begin
                      motor = 2'b10;
                      sentidoMotor = 2'b10;
                    end
                    else begin
                      motor = 2'b00;
                      sentidoMotor = 2'b00;
                    end
                  end
                
                endcase
              
              end
            end
          	
          	p3: begin // Estado: andar 3
              if ((e3 || i3) && s3) begin // se um dos bostões do andar 3 estejam pressionados e o andar atual do elevador seja 
                case (elev_parado) //inicia o case da submáquina que para o elevador
                  desativar_motor: begin // inicia o estado de desativar o motor
                    sentidoMotor = motor;
                    motor = 2'b00; // motor irá para 0
                    if (motor == 2'b00) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = pa; // se atendido, submáquina irá para o próximo estado
                    end 
                    else begin // se não...
                      elev_parado = desativar_motor; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  pa: begin // inicia o estado de abrir a porta
                    port3 = 1; // abre a porta 3
                    if (port3 == 1) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = count_down; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = pa; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  count_down: begin // inicia o estado de aguardar 
                    $display("Contando = %d,    time=%0d", cont + 1, $time);
                    cont = cont + 1; // incrementa o contador
                    if (cont == time_porta) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      cont = 0; // zera o contador antes de ir para o próximo estado para que possa ser usado novamente futuramente
                      elev_parado = pf; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = count_down; // ...estado da submáquina será mantido o mesmo
                    end
                  end
                  
                  pf: begin
                    port3 = 0; // fecha a porta do andar 3
                    if(port3 == 0) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
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
                case (sentidoMotor)
                  2'b01:begin
                    if(e4 || i4 || e5 || i5) begin
                      motor = 2'b01;
                      sentidoMotor = 2'b01;
                    end 
                    else if(e1 || i1 || e2 || i2) begin
                      motor = 2'b10;
                      sentidoMotor = 2'b10;
                    end
                    else begin
                      motor = 2'b00;
                      sentidoMotor = 2'b00;
                    end
                  end
                  
                  2'b10:begin
                    if(e1 || i1 || e2 || i2) begin
                      motor = 2'b10;
                      sentidoMotor = 2'b10;
                    end 
                    else if(e4 || i4 || e5 || i5) begin
                      motor = 2'b01;
                      sentidoMotor = 2'b01;
                    end
                    else begin
                      motor = 2'b00;
                      sentidoMotor = 2'b00;
                    end
                  end
                  
                  2'b00:begin
                    if(e4 || i4 || e5 || i5) begin
                      motor = 2'b01;
                      sentidoMotor = 2'b01;
                    end 
                    else if(e1 || i1 || e2 || i2) begin
                      motor = 2'b10;
                      sentidoMotor = 2'b10;
                    end
                    else begin
                      motor = 2'b00;
                      sentidoMotor = 2'b00;
                    end
                  end
                
                endcase
              
              end
            end
          	
          	p4: begin // Estado: andar 4
              if ((e4 || i4) && s4) begin // se um dos bostões do andar 4 estejam pressionados e o andar atual do elevador seja 
                case (elev_parado) //inicia o case da submáquina que para o elevador
                  desativar_motor: begin // inicia o estado de desativar o motor
                    sentidoMotor = motor;
                    motor = 2'b00; // motor irá para 0
                    if (motor == 2'b00) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = pa; // se atendido, submáquina irá para o próximo estado
                    end 
                    else begin // se não...
                      elev_parado = desativar_motor; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  pa: begin // inicia o estado de abrir a porta
                    port4 = 1; // abre a porta 4
                    if (port4 == 1) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = count_down; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = pa; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  count_down: begin // inicia o estado de aguardar 
                    $display("Contando = %d,    time=%0d", cont + 1, $time);
                    cont = cont + 1; // incrementa o contador
                    if (cont == time_porta) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      cont = 0; // zera o contador antes de ir para o próximo estado para que possa ser usado novamente futuramente
                      elev_parado = pf; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = count_down; // ...estado da submáquina será mantido o mesmo
                    end
                  end
                  
                  pf: begin
                    port4 = 0; // fecha a porta do andar 4
                    if(port4 == 0) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
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
                case (sentidoMotor)
                  2'b01:begin
                    if(e5 || i5) begin
                      motor = 2'b01;
                      sentidoMotor = 2'b01;
                    end 
                    else if(e1 || i1 || e2 || i2 || e3 || i3) begin
                      motor = 2'b10;
                      sentidoMotor = 2'b10;
                    end
                    else begin
                      motor = 2'b00;
                      sentidoMotor = 2'b00;
                    end
                  end
                  
                  2'b10:begin
                    if(e1 || i1 || e2 || i2 || e3 || i3) begin
                      motor = 2'b10;
                      sentidoMotor = 2'b10;
                    end 
                    else if(e5 || i5) begin
                      motor = 2'b01;
                      sentidoMotor = 2'b01;
                    end
                    else begin
                      motor = 2'b00;
                      sentidoMotor = 2'b00;
                    end
                  end
                  
                  2'b00:begin
                    if(e5 || i5) begin
                      motor = 2'b01;
                      sentidoMotor = 2'b01;
                    end 
                    else if(e1 || i1 || e2 || i2 || e3 || i3) begin
                      motor = 2'b10;
                      sentidoMotor = 2'b10;
                    end
                    else begin
                      motor = 2'b00;
                      sentidoMotor = 2'b00;
                    end
                  end
                
                endcase
              
              end
            end
          
          	p5: begin // Estado: andar 5
              if ((e5 || i5) && s5) begin // se um dos bostões do andar 5 estejam pressionados e o andar atual do elevador seja 
                case (elev_parado) //inicia o case da submáquina que para o elevador
                  desativar_motor: begin // inicia o estado de desativar o motor
                    sentidoMotor = motor;
                    motor = 2'b00; // motor irá para 0
                    if (motor == 2'b00) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = pa; // se atendido, submáquina irá para o próximo estado
                    end 
                    else begin // se não...
                      elev_parado = desativar_motor; // ...estado da submáquina será mantido o mesmo
                    end
                  end
                  pa: begin // inicia o estado de abrir a porta
                    port5 = 1; // abre a porta 5
                    if (port5 == 1) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      elev_parado = count_down; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = pa; // ...estado da submáquina será mantido o mesmo
                    end
                  end

                  count_down: begin // inicia o estado de aguardar 
                    $display("Contando = %d,    time=%0d", cont + 1, $time);
                    cont = cont + 1; // incrementa o contador
                    if (cont == time_porta) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
                      cont = 0; // zera o contador antes de ir para o próximo estado para que possa ser usado novamente futuramente
                      elev_parado = pf; // se atendido, submáquina irá para o próximo estado
                    end
                    else begin // se não...
                      elev_parado = count_down; // ...estado da submáquina será mantido o mesmo
                    end
                  end
                  
                  pf: begin
                    port5 = 0; // fecha a porta do andar 5
                    if(port5 == 0) begin // if para testar se a condição para ir para o próximo estado da submáquina foi atendida
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
                motor = 2'b10;   // Motor Descendo
                sentidoMotor = 2'b10;
              end else begin
                motor = 2'b00;   // Motor parado
                sentidoMotor = 2'b00;
              end
            end
            
            default: begin
                estado <= p1; // Estado padrão é o andar 1
            end
        endcase
		end else begin
				motor = 2'b00;
				sentidoMotor = 2'b00;
				alerta = alerta;
			 end 
		end
   end
  
  // Always externos para que sempre que um botão seja pressionado, ative as variáveis de armazenamento. Também servem para desativar as variáveis de armazenamento, sempre que o elevador terminar as transições da sub-máquina para abrir a porta
  
   always @(posedge be1 or negedge sp1 or posedge noStopIn or posedge alerta or posedge reset) begin
		if(!sp1 || noStopIn || alerta || reset) begin 
			e1 <= 0;
		end else if(be1) begin
			e1 <= 1;
		end else begin
			e1 <= be1;
		end
   end

   always @(posedge bi1 or negedge sp1 or posedge alerta_leds or posedge reset)begin
		if(!sp1 || reset) begin
			i1 <= 0;
			l1 <= 0; // leds dos botões internos se atualizam juntamente com a memória dos botões...
		end else if(bi1) begin
			i1 <= 1;
			l1 <= 1; //... se repete para todos os aways de chamada de botões internos
		end else if(alerta_leds) begin
			i1 <= 0;
			l1 <= ~l1;
		end else i1 <= bi1;
	end

   always @(posedge be2 or negedge sp2 or posedge noStopIn or posedge alerta or posedge reset) begin
	   if(!sp2 || noStopIn || alerta || reset) begin
			e2 <= 0;
      end else if(be2) begin
			e2 <= 1;
      end else begin
			e2 <= be2;
		end
   end

   always @(posedge bi2 or negedge sp2 or posedge alerta_leds or posedge reset)begin
		if(!sp2 || reset) begin
			i2 <= 0;
			l2 <= 0; // leds dos botões internos se atualizam juntamente com a memória dos botões...
		end else if(bi2) begin
			i2 <= 1;
			l2 <= 1; //... se repete para todos os aways de chamada de botões internos
		end else if(alerta_leds) begin
			i2 <= 0;
			l2 <= ~l2;
		end else i2 <= bi2;
	end

   always @(posedge be3 or negedge sp3 or posedge noStopIn or posedge alerta or posedge reset) begin
	   if(!sp3 || noStopIn || alerta || reset) begin
			e3 <= 0;
      end else if(be3) begin
			e3 <= 1;
      end else begin
			e3 <= be3;
		end
   end

   always @(posedge bi3 or negedge sp3 or posedge alerta_leds or posedge reset)begin
		if(!sp3 || reset) begin
			i3 <= 0;
			l3 <= 0; // leds dos botões internos se atualizam juntamente com a memória dos botões...
		end else if(bi3) begin
			i3 <= 1;
			l3 <= 1; //... se repete para todos os aways de chamada de botões internos
		end else if(alerta_leds) begin
			i3 <= 0;
			l3 <= ~l3;
		end else i3 <= bi3;
	end

   always @(posedge be4 or negedge sp4 or posedge noStopIn or posedge alerta or posedge reset) begin
	   if(!sp4 || noStopIn || alerta || reset) begin
			e4 <= 0;
      end else if(be4) begin
			e4 <= 1;
      end else begin
			e4 <= be4;
		end
   end

   always @(posedge bi4 or negedge sp4 or posedge alerta_leds or posedge reset)begin
		if(!sp4 || reset) begin
			i4 <= 0;
			l4 <= 0; // leds dos botões internos se atualizam juntamente com a memória dos botões...
		end else if(bi4) begin
			i4 <= 1;
			l4 <= 1; //... se repete para todos os aways de chamada de botões internos
		end else if(alerta_leds) begin
			i4 <= 0;
			l4 <= ~l4;
		end else i4 <= bi4;
	end

   always @(posedge be5 or negedge sp5 or posedge noStopIn or posedge alerta or posedge reset) begin
	   if(!sp5 || noStopIn || alerta || reset) begin
			e5 <= 0;
      end else if(be5) begin
			e5 <= 1;
      end else begin
			e5 <= be5;
		end
   end
	
   always @(posedge bi5 or negedge sp5 or posedge alerta_leds or posedge reset)begin
		if(!sp5 || reset) begin
			i5 <= 0;
			l5 <= 0; // leds dos botões internos se atualizam juntamente com a memória dos botões...
		end else if(bi5) begin
			i5 <= 1;
			l5 <= 1; //... se repete para todos os aways de chamada de botões internos
		end else if(alerta_leds) begin
			i5 <= 0;
			l5 <= ~l5;
		end else i5 <= bi5;
	end
  
	
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			estado = p1;
			alerta = 0;
		end else begin
		
			case({s1, s2, s3, s4, s5})
				5'b10000: begin
					estado = p1;
					alerta = 0;
				end
				
				5'b01000: begin
					estado = p2;
					alerta = 0;
				end
				
				5'b00100: begin
					estado = p3;
					alerta = 0;
				end
				
				5'b00010: begin
					estado = p4;
					alerta = 0;
				end
				
				5'b00001: begin
					estado = p5;
					alerta = 0;
				end
				
				5'b00000: begin
					alerta = 0;
				end
				
				default: begin
					alerta = 1;
				end 
			endcase
			
			if (alerta == 1) begin
				alerta = alerta;
			end else begin
				case({port1, port2, port3, port4, port5})
					5'b10000: begin
						alerta = 0;
					end
					
					5'b01000: begin
						alerta = 0;
					end
					
					5'b00100: begin
						alerta = 0;
					end
					
					5'b00010: begin
						alerta = 0;
					end
					
					5'b00001: begin
						alerta = 0;
					end
					
					5'b00000: begin
						alerta = 0;
					end
					
					default: begin
					
						alerta = 1;
					end 
				endcase 
			end
		end
   end
  
  always @(noStopIn) begin 
    noStopOut = noStopIn;
  end
  
	always @(noStopIn) begin // always para que toda vez que o noStopIn for atualizado, também atualizar o NostopOut
		noStopOut = noStopIn;
	end
	 
	always @(estado or clock) begin // always para controlar os displays, sendo sensível, tanto ao alerta, como a mudança de pavimento
		case (alerta) // Caso o alerta...
			0: begin // ... esteja desligado ...
				case(estado + 1) // verifique o valor do pavimento e envie um valor equivalente ao pavimento no displayInterno
					4'b0000 : displayInterno = 7'b1000000;
					4'b0001 : displayInterno = 7'b1111001;
					4'b0010 : displayInterno = 7'b0100100;
					4'b0011 : displayInterno = 7'b0110000;
					4'b0100 : displayInterno = 7'b0011001;
					4'b0101 : displayInterno = 7'b0010010;
					4'b0110 : displayInterno = 7'b0000010;
					4'b0111 : displayInterno = 7'b1111000;
					4'b1000 : displayInterno = 7'b0000000;
					4'b1001 : displayInterno = 7'b0011000;      
					4'b1010 : displayInterno = 7'b0001000;
					4'b1011 : displayInterno = 7'b0000011;
					4'b1100 : displayInterno = 7'b1000110;
					4'b1101 : displayInterno = 7'b0100001;
					4'b1110 : displayInterno = 7'b0000110;		
					4'b1111 : displayInterno = 7'b0001110;
			 
				endcase
			end
			
			1: begin // Caso o alerta esteja ligado, envie essa combinação no display 
				displayInterno = 7'b0000110; // Obs.:Não sabemos como fazer o E no display ainda :(
				
				if (cont_led < (time_porta / 5)) begin
					cont_led ++;
					alerta_leds = 0;
				end else begin
					alerta_leds = 1;
					cont_led = 0;
				end
				
			end
		endcase
	end
    
   
endmodule

// Divisor de frequencia de 50MHz para 1MHz

module divfreq(input reset, clock, output logic clk_i);
    
	parameter num_clock = 3;
	int contador;
  
  always @(posedge clock or posedge reset) begin
    if(reset) begin
      contador  = 0;
      clk_i = 0;
    end
    else
      if( contador <= num_clock)
        contador = contador + 1;
      else begin
        clk_i = ~clk_i;
        contador = 0;
      end
  end
endmodule



/*module BCDto7SEGMENT( input logic[3:0] bcd, output logic [6:0] Seg );

 
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



module conv_motor( input int entrada, output logic [2:0] motor );
always begin

	 case(entrada)
	 
		  0: motor = 3'b010;
		  1: motor = 3'b100;
		 -1: motor = 3'b001;
		 
		 default: motor = 3'b010;
	 
	 endcase
 
 end

 
endmodule
*/
module controladora (input     				reset, 
														clock, 
														noStopA, noStopB,
														be1Up, be2Up, be2Down, be3Up, be3Down, be4Up, be4Down, be5Down,
														s1A, s2A, s3A, s4A, s5A, 
														s1B, s2B, s3B, s4B, s5B,
							input logic [1:0]		sentidoMotorA, sentidoMotorB,
							input logic				alertaInA, alertaInB,
							output logic			l1Up, l2Up, l2Down, l3Up, l3Down, l4Up, l4Down, l5Down,
							output logic [6:0] 	displayInternoA, displayInternoB, 
							output logic			alertaOutA, alertaOutB,
							output logic			be1A, be2A, be3A, be4A, be5A,
							output logic			be1B, be2B, be3B, be4B, be5B
);

   import my_functions::*; // importando todo o pacote de funções


	parameter num_call = 8;
	parameter int MAX_INT = 2147483647;
	
	//Máquinas de estados//
	
	enum logic [4:0] {
		verific_disp, 	// Verifica disponibilidade
		calc_dist, 		// Calcula a distância dos disponíveis
		selec_elev, 	// Seleciona um dos elevadores
		envia_sinal,	// Envia o sinal para o elevador escolhido no andar específico
		desativa_sinal // Desativa_sinal o sinal para ser usado futuramente
	} control;
	
	enum logic [4:0] {
		verifica_alerta,	// Verifica disponibilidade de acordo com o alerta
		verifica_nostop, 	// Verifica disponibilidade de acordo com o NoStop
		pega_sinal, 		// Pega os valores de andar e sentido da chamada
		verifica_sentido, 	// Verifica disponibilidade do elevador de acordo com o sentido do motor do elevadorX
		sub_final
	} sub_verifica;
	
	
	
	//Typedef//
	
	typedef enum logic [1:0]{
		PARADO = 2'b00,
		SUBINDO = 2'b01,
		DESCENDO = 2'b10
	} motor;
		motor motorA, motorB;

	typedef enum logic [3:0] {
    P1 = 4'b0001, // 1
    P2 = 4'b0010, // 2
    P3 = 4'b0011, // 3
    P4 = 4'b0100, // 4
    P5 = 4'b0101  // 5
	} pavimentos;
		pavimentos pavimentoA, pavimentoB;
		
	typedef struct {
		logic ativa;
		pavimentos andar;
		motor sentido;
	} call; // objeto call, que armazena qual o andar solicitado, o sentido da solicitação e se a chamada está ativa, ou não.
		
	//Assigns//	

	assign motorA = motor'(sentidoMotorA);
	assign motorB = motor'(sentidoMotorB);
	
	
	call chamadas [num_call] = '{
    '{ativa: 0, andar: P1, sentido: SUBINDO },
    '{ativa: 0, andar: P2, sentido: SUBINDO },
    '{ativa: 0, andar: P2, sentido: DESCENDO},
    '{ativa: 0, andar: P3, sentido: SUBINDO },
    '{ativa: 0, andar: P3, sentido: DESCENDO},
    '{ativa: 0, andar: P4, sentido: SUBINDO },
    '{ativa: 0, andar: P4, sentido: DESCENDO},
    '{ativa: 0, andar: P5, sentido: DESCENDO}
}; // Lista com todas as chamadas que a controladora pode receber.

	logic 		dispA, dispB, dispTotal, 	// Variáveis que determinam a disposição dos elevadores para uma chamada X, dispTotal serve para resetar a máquina, se nenhum dos elevadores puder atender naquele momento
					d_botoes0, d_botoes1, d_botoes2, d_botoes3, d_botoes4, d_botoes5, d_botoes6, d_botoes7, // variáveis para desativar uma chamada
					d_leds0, d_leds1, d_leds2, d_leds3, d_leds4, d_leds5, d_leds6, d_leds7; // variáveis para desativar os leds
	pavimentos 	andar_call; 					// Utilizada para armazenar temporariamente o andar da chamada que está sendo tratada
	motor 		sentido_call; 					// Utilizada para armazenar temporariamente o andar da chamada que está sendo tratada
	int 			distanciaA, distanciaB;		// Utilizada para armazenar temporariamente a distância do andar atual até o andar da chamada		
	enum logic [0:0] {
		A,
		B
	} elev_slc; 									// Utilizada para armazenar temporariamente o elevador selecionado para a chamada
	int current_call_index = 0;				// Utilizada para armazenar o index da chamada atual sendo verificada.
	logic [0:0] d_botoes[8]; 					//Variáveis utilizadas para desativar uma solicitação
	
	
	
	always @(posedge clock or posedge reset) begin
		if (reset == 1) begin 
			be1A <= 0; be2A <= 0; be3A <= 0; be4A <= 0; be5A <= 0;
			be1B <= 0; be2B <= 0; be3B <= 0; be4B <= 0; be5B <= 0;
			dispA <= 0; dispB <= 0; dispTotal <= 1;
			d_botoes0 <= 0;
			d_botoes1 <= 0;
			d_botoes2 <= 0;
			d_botoes3 <= 0;
			d_botoes4 <= 0;
			d_botoes5 <= 0;
			d_botoes6 <= 0;
			d_botoes7 <= 0;
			current_call_index <= 0;
			control <= verific_disp;
			sub_verifica <= verifica_alerta;
			
		end else begin
			if (current_call_index == 8) begin
				current_call_index = 0;
			end else begin
				current_call_index = current_call_index;
			end
			
			if (chamadas[current_call_index].ativa) begin // Se a chamada estiver ativa, verifica ela
				case(control)
					verific_disp: begin
						case(sub_verifica)
							verifica_alerta: begin // Verifica A e B de acordo com o Alerta
								if(alertaInA == 1) begin
									dispA = 0;
								end else begin
									dispA = 1;
								end
								
								if(alertaInB == 1) begin
									dispB = 0;
								end else begin
									dispB = 1;
								end
								
								if (dispA || dispB) begin
									dispTotal = 1;
								end else begin
									dispTotal = 0;
								end
								
								
								if (dispTotal) begin
									sub_verifica = verifica_nostop; // Se houver ao menos um elevador disponível, irá para o próximo estado
								end else begin
									current_call_index ++; // Caso não, irá verificar a próxima chamada, se mantendo no estado atual (inicial)
								end
							end
							
							verifica_nostop: begin // Verifica A e B de acordo com o noStop
								if(noStopA == 1) begin
									dispA = 0;
								end else begin
									dispA = 1;
								end
								
								if(noStopB == 1) begin
									dispB = 0;
								end else begin
									dispB = 1;
								end
								
								if (dispA || dispB) begin
									dispTotal = 1;
								end else begin
									dispTotal = 0;
								end
								
								if (dispTotal) begin
									sub_verifica = pega_sinal; // Se houver ao menos um elevador disponível, irá para o próximo estado
								end else begin
									sub_verifica = verifica_alerta; // Caso não, irá verificar a próxima chamada, voltando para o estado inicial
									current_call_index ++;
								end
							end
							
							pega_sinal: begin
								andar_call = chamadas[current_call_index].andar; // Coleta o andar da chamada
								sentido_call = chamadas[current_call_index].sentido; // Coleta o sentido da chamada
								sub_verifica = verifica_sentido; // Vai para o próximo estado
							end
							
							verifica_sentido: begin
								if ((sentido_call == motorA) || (motorA == PARADO)) begin // Se a chamada estiver no mesmo sentido do motor, ou se o motor estiver parado
									case(motorA)
										SUBINDO: begin
											if(andar_call > pavimentoA) begin // Se puder pegar carona subindo, disposição é verdadeira
												dispA = 1;
											end else begin
												dispA = 0;
											end
										end
										
										DESCENDO: begin
											if(andar_call < pavimentoA) begin // Se puder pegar carona descendo, disposição é verdadeira
												dispA = 1;
											end else begin
												dispA = 0;
											end
										end
										
										PARADO: begin // Se o elevador estiver parado ele sempre deverá ser apto para atender.
											dispA = 1;
										end
									endcase
								end else begin // Se ele não atender as condições de poder dar carona ou não estiver parado, não estará disponível
									dispA = 0;
								end
								
								if ((sentido_call == motorB) || (motorB == PARADO)) begin // Se a chamada estiver no mesmo sentido do motor, ou se o motor estiver parado
									case(motorB)
										SUBINDO: begin
											if(andar_call > pavimentoB) begin // Se puder pegar carona subindo, disposição é verdadeira
												dispB = 1;
											end else begin
												dispB = 0;
											end
										end
										
										DESCENDO: begin
											if(andar_call < pavimentoB) begin // Se puder pegar carona descendo, disposição é verdadeira
												dispB = 1;
											end else begin
												dispB = 0;
											end
										end
										
										PARADO: begin // Se o elevador estiver parado ele sempre deverá ser apto para atender.
											dispB = 1;
										end
									endcase
								end else begin // Se ele não atender as condições de poder dar carona ou não estiver parado, não estará disponível
									dispB = 0;
								end
								
								sub_verifica = sub_final;
							end
						endcase
						
						if (!(dispA || dispB)) begin 			// Se nenhum dos elevadores estiver disponível...
							sub_verifica = verifica_alerta; 	// ... reseta a submáquina a seu estado inicial...
							current_call_index ++; 								// ... e parte para a verificação da próxima chamada.
						end else if (sub_verifica == sub_final)begin 	// Se a sub-máquina tiver finalizado..
							sub_verifica = verifica_alerta; 	// ... reseta a submaquina para ser usada futuramente...
							control = calc_dist; 				// ...e a máquina principal irá para o próximo estado							
						end else begin
							sub_verifica = sub_verifica;
						end
					end
					
					calc_dist: begin
						if (dispA) begin 											// Se A estiver disponível
							distanciaA = abs(andar_call - pavimentoA);	// Calcule o módulo da distancia e atribua na variável
						end else begin 											// Se o elevador não estiver disponível...
							distanciaA = MAX_INT;								// ...atribua o valor mais alto (ajudará para garantir que não será selecionado depois)
						end
						
						if (dispB) begin 											// Se A estiver disponível
							distanciaB = abs(andar_call - pavimentoB);	// Calcule o módulo da distancia e atribua na variável
						end else begin 											// Se o elevador não estiver disponível...
							distanciaB = MAX_INT;								// ...atribua o valor mais alto (ajudará para garantir que não será selecionado depois)
						end
						
						control = selec_elev; // Vai para o próximo estado após os cálculos	
					end
					
					selec_elev: begin
						if (distanciaA <= distanciaB) begin // Se a distância de A for menor/igual que a de B, seleciona A.
							elev_slc = A; 	// Haverá uma prioridade em um dos elevadores, nesse caso A, considere A elevador de uso comum e B o de serviço.
						end else begin		// Se o elevador escolhido não for A...
							elev_slc = B;
						end
						
						control = envia_sinal; // Vai para o próximo estado após escolher um elevador.
					end
					
					envia_sinal: begin
						if (elev_slc == A) begin // Se o elevador selecionado for o A
							case(andar_call) // Verifique qual o andar da chamada e envie o sinal para ele no elevador A
								P1: begin
									be1A = 1;
								end
								
								P2: begin
									be2A = 1;
								end
								
								P3: begin
									be3A = 1;
								end
								
								P4: begin
									be4A = 1;
								end
								
								P5: begin
									be5A = 1;
								end
							endcase
						end else begin // Se o elevador selecionado não for o A, será o B
							case(andar_call) // Verifique qual o andar da chamada e envie o sinal para ele no elevador B
									P1: begin
										be1B = 1;
									end
									
									P2: begin
										be2B = 1;
									end
									
									P3: begin
										be3B = 1;
									end
									
									P4: begin
										be4B = 1;
									end
									
									P5: begin
										be5B = 1;
									end
								endcase
						end
						
						control = desativa_sinal; // Máquina vai para seu último estado
					end
					
					desativa_sinal: begin
						case(current_call_index)
							0:begin
								d_botoes0 = 1;
							end
							
							1:begin
								d_botoes1 = 1;
							end
							
							2:begin
								d_botoes2 = 1;
							end
							
							3:begin
								d_botoes3 = 1;
							end
							
							4:begin
								d_botoes4 = 1;
							end
							
							5:begin
								d_botoes5 = 1;
							end
							
							6:begin
								d_botoes6 = 1;
							end
							
							7:begin
								d_botoes7 = 1;
							end
						endcase
						
						if (elev_slc == A) begin // Se o elevador selecionado for o A
							case(andar_call) // Verifique qual o andar da chamada e desative o sinal para ele no elevador A
								P1: begin
									be1A = 0;
								end
								
								P2: begin
									be2A = 0;
								end
								
								P3: begin
									be3A = 0;
								end
								
								P4: begin
									be4A = 0;
								end
								
								P5: begin
									be5A = 0;
								end
							endcase
						end else begin // Se o elevador selecionado não for o A, será o B
							case(andar_call) // Verifique qual o andar da chamada e desative o sinal para ele no elevador B
								P1: begin
									be1B = 0;
								end
								
								P2: begin
									be2B = 0;
								end
								
								P3: begin
									be3B = 0;
								end
								
								P4: begin
									be4B = 0;
								end
								
								P5: begin
									be5B = 0;
								end
							endcase
						end
						
						case(current_call_index)
							0:begin
								d_botoes0 = 0;
							end
							
							1:begin
								d_botoes1 = 0;
							end
							
							2:begin
								d_botoes2 = 0;
							end
							
							3:begin
								d_botoes3 = 0;
							end
							
							4:begin
								d_botoes4 = 0;
							end
							
							5:begin
								d_botoes5 = 0;
							end
							
							6:begin
								d_botoes6 = 0;
							end
							
							7:begin
								d_botoes7 = 0;
							end
						endcase
						
						current_call_index ++; 	// Nesse ponto a máquina de estados terminou de avaliar a chamada e irá para analisar a próxima.
						control = verific_disp; // A máquina se reseta para ser usada na próxima chamada. 
					end
				endcase
			end else begin
				current_call_index ++; // Se a chamada não estiver ativa, verifica a próxima
			end
			
		end

	end
	
	// Always para ativação dos leds e registro de memória das chamadas
	
	always @(posedge be1Up or posedge d_botoes0 or posedge d_leds0 or posedge reset)begin
      if(reset) begin
			chamadas[0].ativa <= 0;
			l1Up <= 0;
		end else if (d_leds0) begin
			l1Up <= 0;
      end else if (d_botoes0) begin
			chamadas[0].ativa <= 0;
		end else if(be1Up) begin 
			chamadas[0].ativa <= 1;
			l1Up <= 1;
      end else begin
			chamadas[0].ativa <= be1Up;
		end
   end
	
	always @(posedge be2Up or posedge d_botoes1 or posedge d_leds1 or posedge reset)begin
      if(reset) begin
			chamadas[1].ativa <= 0;
			l2Up <= 0;
		end else if (d_leds1) begin
			l2Up <= 0;
      end else if (d_botoes1) begin
			chamadas[1].ativa <= 0;
		end else if(be2Up) begin 
			chamadas[1].ativa <= 1;
			l2Up <= 1;
      end else begin
			chamadas[1].ativa <= be2Up;
		end
   end
	
	always @(posedge be3Up or posedge d_botoes3 or posedge d_leds3 or posedge reset)begin
      if(reset) begin
			chamadas[3].ativa <= 0;
			l3Up <= 0;
		end else if (d_leds3) begin
			l3Up <= 0;
      end else if (d_botoes3) begin
			chamadas[3].ativa <= 0;
		end else if(be3Up) begin 
			chamadas[3].ativa <= 1;
			l3Up <= 1;
      end else begin
			chamadas[3].ativa <= be3Up;
		end
   end
	
	always @(posedge be4Up or posedge d_botoes5 or posedge d_leds5 or posedge reset)begin
      if(reset) begin
			chamadas[5].ativa <= 0;
			l4Up <= 0;
		end else if (d_leds5) begin
			l4Up <= 0;
      end else if (d_botoes5) begin
			chamadas[5].ativa <= 0;
		end else if(be4Up) begin 
			chamadas[5].ativa <= 1;
			l4Up <= 1;
      end else begin
			chamadas[5].ativa <= be4Up;
		end
   end
	
	always @(posedge be2Down or posedge d_botoes2 or posedge d_leds2 or posedge reset)begin
      if(reset) begin
			chamadas[2].ativa <= 0;
			l2Down <= 0;
		end else if (d_leds2) begin
			l2Down <= 0;
      end else if (d_botoes2) begin
			chamadas[2].ativa <= 0;
		end else if(be2Down) begin 
			chamadas[2].ativa <= 1;
			l2Down <= 1;
      end else begin
			chamadas[2].ativa <= be2Down;
		end
   end
	
	always @(posedge be3Down or posedge d_botoes4 or posedge d_leds4 or posedge reset)begin
      if(reset) begin
			chamadas[4].ativa <= 0;
			l3Down <= 0;
		end else if (d_leds4) begin
			l3Down <= 0;
      end else if (d_botoes4) begin
			chamadas[4].ativa <= 0;
		end else if(be3Down) begin 
			chamadas[4].ativa <= 1;
			l3Down <= 1;
      end else begin
			chamadas[4].ativa <= be3Down;
		end
   end
	
	always @(posedge be4Down or posedge d_botoes6 or posedge d_leds6 or posedge reset)begin
      if(reset) begin
			chamadas[6].ativa <= 0;
			l4Down <= 0;
		end else if (d_leds6) begin
			l4Down <= 0;
      end else if (d_botoes6) begin
			chamadas[6].ativa <= 0;
		end else if(be4Down) begin 
			chamadas[6].ativa <= 1;
			l4Down <= 1;
      end else begin
			chamadas[6].ativa <= be4Down;
		end
   end
		
	always @(posedge be5Down or posedge d_botoes7 or posedge d_leds7 or posedge reset)begin
      if(reset) begin
			chamadas[7].ativa <= 0;
			l5Down <= 0;
		end else if (d_leds7) begin
			l5Down <= 0;
      end else if (d_botoes7) begin
			chamadas[7].ativa <= 0;
		end else if(be5Down) begin 
			chamadas[7].ativa <= 1;
			l5Down <= 1;
      end else begin
			chamadas[7].ativa <= be5Down;
		end
   end
	
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			alertaOutA <= 0;
		end else begin
			case({s1A, s2A, s3A, s4A, s5A})
				5'b10000: begin
					pavimentoA <= P1;
					alertaOutA <= 0;
				end
				
				5'b01000: begin
					pavimentoA <= P2;
					alertaOutA <= 0;
				end
				
				5'b00100: begin
					pavimentoA <= P3;
					alertaOutA <= 0;
				end
				
				5'b00010: begin
					pavimentoA <= P4;
					alertaOutA <= 0;
				end
				
				5'b00001: begin
					pavimentoA <= P5;
					alertaOutA <= 0;
				end
				
				5'b00000: begin
					alertaOutA <= 0;
				end
				
				default: begin
					alertaOutA <= 1;
				end 
			endcase
		end
   end
	
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			alertaOutB <= 0;
		end else begin
			case({s1B, s2B, s3B, s4B, s5B})
				5'b10000: begin
					pavimentoB <= P1;
					alertaOutB <= 0;
				end
				
				5'b01000: begin
					pavimentoB <= P2;
					alertaOutB <= 0;
				end
				
				5'b00100: begin
					pavimentoB <= P3;
					alertaOutB <= 0;
				end
				
				5'b00010: begin
					pavimentoB <= P4;
					alertaOutB <= 0;
				end
				
				5'b00001: begin
					pavimentoB <= P5;
					alertaOutB <= 0;
				end
				
				5'b00000: begin
					alertaOutB <= 0;
				end
				
				default: begin
					alertaOutB <= 1;
				end 
			endcase
		end
   end
	
	always @(pavimentoA or alertaOutA) begin // always para controlar os displays, sendo sensível, tanto ao alerta, como a mudança de pavimento
		case (alertaOutA) // Caso o alerta...
			0: begin // ... esteja desligado ...
				case(pavimentoA) // verifique o valor do pavimento e envie um valor equivalente ao pavimento no displayInterno
					4'b0000 : displayInternoA = 7'b1000000;
					4'b0001 : displayInternoA = 7'b1111001;
					4'b0010 : displayInternoA = 7'b0100100;
					4'b0011 : displayInternoA = 7'b0110000;
					4'b0100 : displayInternoA = 7'b0011001;
					4'b0101 : displayInternoA = 7'b0010010;
					4'b0110 : displayInternoA = 7'b0000010;
					4'b0111 : displayInternoA = 7'b1111000;
					4'b1000 : displayInternoA = 7'b0000000;
					4'b1001 : displayInternoA = 7'b0011000;      
					4'b1010 : displayInternoA = 7'b0001000;
					4'b1011 : displayInternoA = 7'b0000011;
					4'b1100 : displayInternoA = 7'b1000110;
					4'b1101 : displayInternoA = 7'b0100001;
					4'b1110 : displayInternoA = 7'b0000110;		
					4'b1111 : displayInternoA = 7'b0001110;
			 
				endcase
			end
			
			1: begin // Caso o alerta esteja ligado, envie essa combinação no display 
				displayInternoA = 7'b0000110; // Obs.:Não sabemos como fazer o E no display ainda :(
			end
		endcase
	end
	
	always @(pavimentoB or alertaOutB) begin // always para controlar os displays, sendo sensível, tanto ao alerta, como a mudança de pavimento
		case (alertaOutB) // Caso o alerta...
			0: begin // ... esteja desligado ...
				case(pavimentoB) // verifique o valor do pavimento e envie um valor equivalente ao pavimento no displayInterno
					4'b0000 : displayInternoB = 7'b1000000;
					4'b0001 : displayInternoB = 7'b1111001;
					4'b0010 : displayInternoB = 7'b0100100;
					4'b0011 : displayInternoB = 7'b0110000;
					4'b0100 : displayInternoB = 7'b0011001;
					4'b0101 : displayInternoB = 7'b0010010;
					4'b0110 : displayInternoB = 7'b0000010;
					4'b0111 : displayInternoB = 7'b1111000;
					4'b1000 : displayInternoB = 7'b0000000;
					4'b1001 : displayInternoB = 7'b0011000;      
					4'b1010 : displayInternoB = 7'b0001000;
					4'b1011 : displayInternoB = 7'b0000011;
					4'b1100 : displayInternoB = 7'b1000110;
					4'b1101 : displayInternoB = 7'b0100001;
					4'b1110 : displayInternoB = 7'b0000110;		
					4'b1111 : displayInternoB = 7'b0001110;
			 
				endcase
			end
			
			1: begin // Caso o alerta esteja ligado, envie essa combinação no display 
				displayInternoB = 7'b0000110; // Obs.:Não sabemos como fazer o E no display ainda :(
			end
		endcase
	end
	
	always @(pavimentoA or pavimentoB or motorA or motorB or reset) begin // Always para ativar/desativar as variáveis de ativação dos leds
		if (reset) begin
			d_leds0 <= 0;
			d_leds1 <= 0;
			d_leds2 <= 0;
			d_leds3 <= 0;
			d_leds4 <= 0;
			d_leds5 <= 0;
			d_leds6 <= 0;
			d_leds7 <= 0;
		end else begin
			case(pavimentoA)
				P1: begin
					if ((motorA == SUBINDO) || (motorA == PARADO)) begin
						d_leds0 = 1;
					end else begin
						d_leds0 = 0;
					end
				end
				
				P2: begin
					if ((motorA == SUBINDO)) begin
						d_leds1 = 1;
						d_leds2 = 0;
					end else if (motorA == DESCENDO) begin
						d_leds1 = 0;
						d_leds2 = 1;
					end else begin
						d_leds1 = 1;
						d_leds2 = 1;
					end
				end
				
				P3: begin
					if ((motorA == SUBINDO)) begin
						d_leds3 = 1;
						d_leds4 = 0;
					end else if (motorA == DESCENDO) begin
						d_leds3 = 0;
						d_leds4 = 1;
					end else begin
						d_leds3 = 1;
						d_leds4 = 1;
					end
				end
				
				P4: begin
					if ((motorA == SUBINDO)) begin
						d_leds5 = 1;
						d_leds6 = 0;
					end else if (motorA == DESCENDO) begin
						d_leds5 = 0;
						d_leds6 = 1;
					end else begin
						d_leds5 = 1;
						d_leds6 = 1;
					end
				end
				
				P5: begin
					if ((motorA == DESCENDO) || (motorA == PARADO)) begin
						d_leds7 = 1;
					end else begin
						d_leds7 = 0;
					end
				end			
			endcase
			
			case(pavimentoB)
				P1: begin
					if ((motorB == SUBINDO) || (motorB == PARADO)) begin
						d_leds0 = 1;
					end else begin
						d_leds0 = 0;
					end
				end
				
				P2: begin
					if ((motorB == SUBINDO)) begin
						d_leds1 = 1;
						d_leds2 = 0;
					end else if (motorB == DESCENDO) begin
						d_leds1 = 0;
						d_leds2 = 1;
					end else begin
						d_leds1 = 1;
						d_leds2 = 1;
					end
				end
				
				P3: begin
					if ((motorB == SUBINDO)) begin
						d_leds3 = 1;
						d_leds4 = 0;
					end else if (motorB == DESCENDO) begin
						d_leds3 = 0;
						d_leds4 = 1;
					end else begin
						d_leds3 = 1;
						d_leds4 = 1;
					end
				end
				
				P4: begin
					if ((motorB == SUBINDO)) begin
						d_leds5 = 1;
						d_leds6 = 0;
					end else if (motorB == DESCENDO) begin
						d_leds5 = 0;
						d_leds6 = 1;
					end else begin
						d_leds5 = 1;
						d_leds6 = 1;
					end
				end
				
				P5: begin
					if ((motorB == DESCENDO) || (motorB == PARADO)) begin
						d_leds7 = 1;
					end else begin
						d_leds7 = 0;
					end
				end
			endcase
		end
	
	end



endmodule




module seq_pavimento(  	input logic clk, rst, input logic [1:0] motor, 
						output logic s1, s2, s3, s4, s5 
							);
							
int time_p = 50;
int count = 0;
int pavimento = 1;
int time_s = 20; // baixar o sinal de S

always @(posedge clk or posedge rst) begin
	if (rst) begin
			pavimento = 1;
			count = 0;
			s1 = 1;
			s2 = 0;
			s3 = 0;
			s4 = 0;
			s5 = 0;
		end
	else
	 case(pavimento) 

			1 :begin
						if (motor == 2'b00) begin
							s1 = 1;
							s2 = 0;
							s3 = 0;
							s4 = 0;
							s5 = 0;
							end
						else
							if (motor == 2'b01) begin
									if(count >= time_p) begin
										  count = 0;
										  pavimento++;
                                      	  s2 = 1;
										end
									else 
										count ++;
										
									if(count >= time_s) 
										s1 = 0;
									else
										s1 = s1;
								end
							else 
								pavimento <= pavimento;
				end 

					
			2 :begin
						if (motor == 2'b00) begin
							s1 = 0;
							s2 = 1;
							s3 = 0;
							s4 = 0;
							s5 = 0;
							end
						else
								if (motor == 2'b01) begin
										if(count >= time_p) begin
											  count = 0;
											  pavimento++;
                                         	  s3 = 1;
											end
										 else count ++;
										 
										if(count >= time_s) 
											s2 = 0;
										else
											s2 = s2;
									end
								else 
										if (motor == 2'b10) begin
											if(count >= time_p) begin
												  count = 0;
												  pavimento = pavimento--;
                                              	  s1 = 1;
												end
											 else count ++;
										
											if(count >= time_s) 
												s2 = 0;
											else
												s2 = s2;
										end
										else
											pavimento = pavimento;			
				end

				
			3 :begin
						if (motor == 2'b00) begin
							s1 = 0;
							s2 = 0;
							s3 = 1;
							s4 = 0;
							s5 = 0;
							end
						else
								if (motor == 2'b01) begin
										if(count >= time_p) begin
											  count = 0;
											  pavimento++;
                                              s4 = 1;
											end
										 else count ++;
										 
										if(count >= time_s) 
											s3 = 0;
										else
											s3 = s3;
									end
								else 
										if (motor == 2'b10) begin
											if(count >= time_p) begin
												  count = 0;
												  pavimento = pavimento--;
                                                  s2 = 1;
												end
											 else count ++;
										
											if(count >= time_s) 
												s3 = 0;
											else
												s3 = s3;
										end
										else
											pavimento = pavimento;			
				end

				
			4 :begin
						if (motor == 2'b00) begin
							s1 = 0;
							s2 = 0;
							s3 = 0;
							s4 = 1;
							s5 = 0;
							end
						else
								if (motor == 2'b01) begin
										if(count >= time_p) begin
											  count = 0;
											  pavimento++;
                                              s5 = 1;
											end
										 else count ++;
										 
										if(count >= time_s) 
											s4 = 0;
										else
											s4 = s4;
									end
								else 
										if (motor == 2'b10) begin
											if(count >= time_p) begin
												  count = 0;
												  pavimento = pavimento--;
                                                  s3 = 1;
												end
											 else count ++;
										
											if(count >= time_s) 
												s4 = 0;
											else
												s4 = s4;
										end
										else
											pavimento = pavimento;			
				end

				
			5 :begin
						if (motor == 2'b00) begin
							s1 = 0;
							s2 = 0;
							s3 = 0;
							s4 = 0;
							s5 = 1;
							end
						else
							if (motor == 2'b10) begin
									if(count >= time_p) begin
										  count = 0;
										  pavimento = pavimento--;
                                          s4 = 1;
										end
									else 
										count ++;
										
									if(count >= time_s) 
										s5 = 0;
									else
										s5 = s5;
								end
							else 
								pavimento <= pavimento;
				end 
												
			default: pavimento = pavimento;	
	 endcase
	 
	 
 end
endmodule
