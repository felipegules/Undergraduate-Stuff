# ========================================================================================== #
#	Convencoeses registradores FPU:
#		$f12 - syscall de print float
#		$f0 - syscall de read float
#		$f8-$f11 - argumentos de funcoes
#		$f13-$f14 - retorno de funcao
#		$f1-$f7 - temporarios
#		$f24-$31 - salvos
#
#	Na main:
#		$f24 = altura do chao
#		$f25 = Posicao Y atual do passaro
#		$f26 = Posicao X atual do passaro
#		$f27 = tempo atual
#		$f28 = usado para a massa do passaro atual
#		$f29 = guarda o valor da constante elastica do estilingue escolhido
#		$f30 = velocidade inicial y
#		$f31 = velocidade inicial x
# ========================================================================================== #


#===============================================#
#		DADOS NA MEMORIA		#
#===============================================#
.data	

	MSG1: .ascii "     Pontos:    "   # sem z!!		# mensagens LCD
	MSG2: .ascii "     "					# mensagens LCD
	offset:		.float 7
	maxElemLinha:	.word 6
	numFases:	.word 3
	faseAtual:	.word 0
	pontosFase:	.float 0, 0, 0
	
	#PASSAROS
	numBirds:	.float 3, 5, 6				# nro de passaros em cada fase
	birds:		.float 1, 1, 1, -1, -1, -1		# passaros da 1a fase
			.float 0.5, 2, 0.5, 1, 1, -1		# passaros da 2a fase
			.float 2, 0.5, 1, 2, 0.5, 1		# passaros da 3a fase
	
	#PORCOS
	numPigs:	.float 1, 3, 4				# nro de porcos em cada fase
	
	pigXPos:	.float 252, -1, -1, -1, -1, -1		# posicao X dos porcos da 1a fase
			.float 240, 240, 176, -1, -1, -1		# posicao X dos porcos da 2a fase
			.float 272, 240, 240, 240, -1, -1	# posicao X dos porcos da 3a fase
			
	pigYPos:	.float 160, -1, -1, -1, -1, -1		# posicao Y dos porcos da 1a fase
			.float 104, 200, 200, -1, -1, -1		# posicao Y dos porcos da 2a fase
			.float 24, 56, 104, 152, -1, -1		# posicao Y dos porcos da 3a fase
			
	pigExiste:	.float 1.0, -1, -1, -1, -1, -1		# quais porcos da 1a fase existem
			.float 1.0, 1.0, 1.0, -1, -1, -1	# quais porcos da 2a fase existem
			.float 1.0, 1.0, 1.0, 1.0, -1, -1	# quais porcos da 3a fase existem
	#constantes
	separador:	.asciiz ", "
	newl:		.asciiz "\n"
	wordSize:	.word 4
	const2:		.float 2.0
	const1:		.float 1.0
	vartempo:	.float 0.005
	xini:		.float 30
	yini:		.float 184
	ymax:		.float 207
	ymin:		.float 1
	xmax:		.float 319
	gravity:	.float 10.0
	pontosPassaro:	.float 10000
	pontosPorco:	.float 5000
	
	#estilingues
	k1:		.float 1				# constante elastica do estilingue fraco
	k2:		.float 2				# constante elastica do estilingue medio
	k3:		.float 3				# constante elastica do estilingue forte
	posicaoEtg:	.word 0x800B8028			# posicao do estilingue na tela
	
	#Massas dos passaros
	massaRBird:	.float 1				# massa do passaro vermelho
	massaBBird:	.float 0.5				# massa do passaro azul
	massaYBird:	.float 2				# massa do passaro amarelo
	
	#paredes
	numParedes:	.float 2, 3, 4				# numero de paredes em cada fase
	paredesX:	.float 248, 232, -1, -1, -1, -1		# posicao X inicial de cada parede da 1a fase
			.float 224, 288, 114, -1, -1, -1		# posicao X inicial de cada parede da 2a fase
			.float 272, 224, 224, 224, -1, -1	# posicao X inicial de cada parede da 3a fase
			
	paredesY:	.float 184, 168, -1, -1, -1, -1		# posicao Y inicial de cada parede da 1a fase
			.float 112, 128, 160, -1, -1, -1		# posicao Y inicial de cada parede da 2a fase
			.float 32, 64, 112, 160, -1, -1		# posicao Y inicial de cada parede da 3a fase
			
	paredesExpandX:	.float 2, 6, -1, -1, -1, -1		# expansao em X de cada parede da 1a fase
			.float 10, 2, 2, -1, -1, -1		# expansao em X de cada parede da 2a fase
			.float 2, 6, 6, 6, -1, -1		# expansao em X de cada parede da 3a fase
			
	paredesExpandY:	.float 3, 2, -1, -1, -1, -1		# expansao em Y de cada parede da 1a fase
			.float 2, 10, 6, -1, -1, -1		# expansao em Y de cada parede da 2a fase
			.float 22, 2, 2, 2, -1, -1		# expansao em Y de cada parede da 3a fase
	
	#Mensagens
	msgEscolhaEst:	.asciiz "\nEscolha seu estilingue\n\n1. Leve\n2. Mï¿½dio\n3. Pesado\n\n"
	msgVitoria:	.asciiz "\n\nPARABENS VOCï¿½ VENCEU!\n"
	msgDerrota:	.asciiz "\n\nLOSER!\n"
	msgColisao:	.asciiz "\nTANGO DOWN!\n\n"
	msgPontos:	.asciiz "\nPONTUACAO DA FASE ATUAL : "
	msgPontosFinal:	.asciiz "\nPONTUACAO FINAL :"
	
	#IMAGENS DOS ELEMENTOS DA TELA
	#Imagem do Passaro Vermelho
	plotRbird: .word
0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1,0x000000F1, 
0x000000F1, 0x00000004, 0x0000000F, 0x0000000F, 0x00000004, 0x0000000F, 0x0000000F, 0x000000F1, 0x000000F1,0x000000F1, 
0x000000F1, 0x000000F1, 0x00000004, 0x0000000F, 0x0000000F, 0x00000004, 0x0000000F, 0x0000000F, 0x000000F1,0x000000F1, 
0x000000F1, 0x00000004, 0x0000000F, 0x00000004, 0x00000004, 0x0000000F, 0x00000004, 0x00000004, 0x0000000F,0x000000F1, 
0x000000F1, 0x0000000F, 0x0000000F, 0x0000000F, 0x00000000, 0x00000004, 0x00000000, 0x0000000F, 0x0000000F,0x000000F1, 
0x000000FF, 0x0000000F, 0x0000000F, 0x00000004, 0x00000037, 0x0000001F, 0x00000037, 0x00000004, 0x0000000F,0x000000F1, 
0x000000F1, 0x00000004, 0x0000000F, 0x0000000F, 0x0000001F, 0x0000003F, 0x0000003F, 0x00000037, 0x0000000F,0x000000F1, 
0x000000F1, 0x000000F1, 0x00000004, 0x0000000F, 0x00000037, 0x00000037, 0x00000037, 0x0000000F, 0x000000F1,0x000000F1, 
0x000000F1, 0x0000000F, 0x0000000F, 0x00000004, 0x00000004, 0x00000004, 0x0000000F, 0x000000F1, 0x000000F1,0x000000F1, 
0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1,0x000000F1 

	#Imagem do Passaro Azul
	plotBbird: .word
0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1,0x000000F1, 
0x000000F1,0x000000F1, 0x00000037, 0x000000B7, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1,0x000000F1,
0x000000F1,0x000000F1, 0x000000F1, 0x00000037, 0x0000003F, 0x000000B7, 0x000000F1, 0x000000F1, 0x000000F1,0x000000F1,
0x000000F1,0x000000F1, 0x00000037, 0x00000037, 0x00000037, 0x0000003F, 0x00000037, 0x00000037, 0x000000F1,0x000000F1,
0x000000F1,0x000000F1, 0x000000F1, 0x00000037, 0x00000000, 0x00000037, 0x00000000, 0x000000F1, 0x000000F1,0x000000F1,
0x000000FF,0x000000F1, 0x00000037, 0x0000003F, 0x00000037, 0x0000005D, 0x0000005D, 0x000000B7, 0x000000F1,0x000000F1,
0x000000F1,0x0000003F, 0x0000003F, 0x0000003F, 0x0000005D, 0x0000005D, 0x0000005D, 0x0000005D, 0x0000003F,0x000000F1,
0x000000F1,0x00000037, 0x0000003F, 0x0000003F, 0x0000005D, 0x0000005D, 0x0000005D, 0x00000037, 0x0000003F,0x000000F1,
0x000000F1,0x000000F1, 0x00000037, 0x00000037, 0x00000037, 0x0000005D, 0x00000037, 0x0000003F, 0x000000F1,0x000000F1,
0x000000F1,0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1

	#Imagem do Passaro Amarelo
	plotYbird: .word
0x000000F1,0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1,0x000000F1,	
0x000000F1,0x00000092, 0x000000F4, 0x00000092, 0x000000F4, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1,0x000000F1,
0x000000F1,0x000000F1, 0x00000092, 0x000000E0, 0x00000092, 0x00000092, 0x000000F4, 0x000000F1, 0x000000F1,0x000000F1,
0x000000F1,0x000000F1, 0x000000E0, 0x00000092, 0x00000092, 0x000000E0, 0x00000092, 0x00000092, 0x000000F1,0x000000F1,
0x000000F1,0x00000092, 0x000000E0, 0x000000E0, 0x00000000, 0x00000092, 0x00000000, 0x000000F4, 0x000000F4,0x000000F1,
0x000000FF,0x000000E0, 0x000000E0, 0x00000092, 0x00000037, 0x0000001F, 0x00000037, 0x00000092, 0x000000E0,0x000000F1,
0x000000F1,0x000000F1, 0x00000092, 0x000000E0, 0x0000001F, 0x0000003F, 0x0000003F, 0x00000037, 0x000000F1,0x000000F1,
0x000000F1,0x000000E0, 0x000000E0, 0x00000092, 0x00000037, 0x00000037, 0x000000E0, 0x000000F1, 0x000000F1,0x000000F1,
0x000000F1,0x000000F1, 0x00000092, 0x000000E0, 0x00000092, 0x00000092, 0x000000F1, 0x000000F1, 0x000000F1,0x000000F1,
0x000000F1,0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1

	#Imagem do Porco Verde
	plotGpig: .word
0x00000069, 0x00000069, 0x00000035, 0x00000035, 0x00000035, 0x000000F1, 0x00000069, 0x00000069,
0x00000059, 0x00000059, 0x00000035, 0x00000035, 0x00000035, 0x00000059, 0x00000059, 0x00000069,
0x00000035, 0x00000000, 0x00000069, 0x00000069, 0x00000035, 0x00000000, 0x00000035, 0x00000035,
0x00000035, 0x00000069, 0x00000035, 0x00000035, 0x00000069, 0x00000035, 0x00000035, 0x00000035,
0x00000035, 0x00000035, 0x00000035, 0x00000035, 0x00000059, 0x00000035, 0x00000035, 0x00000035,
0x00000069, 0x00000035, 0x00000069, 0x00000059, 0x00000035, 0x00000035, 0x00000035, 0x00000059,
0x000000F1, 0x00000069, 0x00000035, 0x00000035, 0x00000035, 0x00000035, 0x00000059, 0x000000F1,
0x000000F1, 0x000000F1, 0x00000069, 0x00000069, 0x00000059, 0x00000059, 0x000000F1, 0x000000F1

	#Imagem do Estilingue
	plotEtg: .word
 0x00000004, 0x00000004, 0x00000004, 0x000000F1, 0x000000F1, 0x00000004, 0x00000004, 0x0000000,
 0x00000004, 0x00000053, 0x00000004, 0x000000F1, 0x000000F1, 0x00000004, 0x000000B7, 0x00000004,
 0x00000004, 0x00000053, 0x00000004, 0x000000F1, 0x000000F1, 0x00000004, 0x000000B7, 0x00000004,
 0x00000004, 0x0000001F, 0x00000037, 0x0000003F, 0x0000003F, 0x00000004, 0x0000005D, 0x00000004,
 0x00000004, 0x0000001F, 0x0000001F, 0x0000001F, 0x00000037, 0x00000004, 0x0000005D, 0x00000004,
 0x00000004, 0x00000053, 0x0000001F, 0x0000001F, 0x0000001F, 0x00000004, 0x0000005D, 0x00000004,
 0x00000004, 0x00000053, 0x00000004, 0x000000F1, 0x000000F1, 0x00000004, 0x0000005D, 0x00000004,
 0x00000004, 0x00000053, 0x00000004, 0x000000F1, 0x000000F1, 0x00000004, 0x0000005D, 0x00000004,
 0x00000004, 0x00000004, 0x00000004, 0x00000004, 0x00000004, 0x0000005D, 0x0000005D, 0x00000004,
 0x00000004, 0x00000004, 0x0000005D, 0x0000005D, 0x0000005D, 0x0000005D, 0x0000005D, 0x00000004,
 0x00000004, 0x00000004, 0x0000005D, 0x0000005D, 0x0000005D, 0x000000B7, 0x00000004, 0x00000004,
 0x000000F1, 0x00000004, 0x00000053, 0x0000005D, 0x0000005D, 0x000000B7, 0x00000004, 0x000000F1,
 0x000000F1, 0x00000004, 0x00000053, 0x0000005D, 0x0000005D, 0x000000B7, 0x00000004, 0x000000F1,
 0x000000F1, 0x00000004, 0x00000053, 0x0000005D, 0x0000005D, 0x000000B7, 0x00000004, 0x000000F1,
 0x000000F1, 0x00000004, 0x00000053, 0x0000005D, 0x0000005D, 0x000000B7, 0x00000004, 0x000000F1,
 0x000000F1, 0x00000004, 0x00000053, 0x0000005D, 0x0000005D, 0x000000B7, 0x00000004, 0x000000F1,
 0x000000F1, 0x00000004, 0x00000053, 0x0000005D, 0x0000005D, 0x0000005D, 0x00000004, 0x000000F1,
 0x000000F1, 0x00000004, 0x00000053, 0x0000005D, 0x0000005D, 0x0000005D, 0x00000004, 0x000000F1,
 0x000000F1, 0x00000004, 0x00000053, 0x0000005D, 0x0000005D, 0x0000005D, 0x00000004, 0x000000F1,
 0x000000F1, 0x00000004, 0x00000053, 0x0000005D, 0x0000005D, 0x0000005D, 0x00000004, 0x000000F1,
 0x000000F1, 0x00000004, 0x00000053, 0x0000005D, 0x0000005D, 0x0000005D, 0x00000004, 0x000000F1,
 0x00000020, 0x00000004, 0x00000053, 0x0000005D, 0x0000005D, 0x0000005D, 0x00000004, 0x00000020,
 0x00000020, 0x00000004, 0x00000053, 0x00000053, 0x0000005D, 0x0000005D, 0x00000004, 0x00000020,
 0x00000020, 0x00000004, 0x00000004, 0x00000004, 0x00000004, 0x00000004, 0x00000004, 0x00000020
 
 	

	# imagem do estilingue de madeira
	plotEstilingueMadeira: .word
	0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 
	0xED, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0x04, 0x04, 0x04, 0xF4, 0xF4, 0x04, 0x04, 0x04, 0xF4, 0xED, 
	0xED, 0xF4, 0x04, 0x53, 0x04, 0xF4, 0xF4, 0x04, 0xB7, 0x04, 0xF4, 0xED, 
	0xED, 0xF4, 0x04, 0x53, 0x04, 0xF4, 0xF4, 0x04, 0xB7, 0x04, 0xF4, 0xED, 
	0xED, 0xF4, 0x04, 0x1F, 0x37, 0x3F, 0x3F, 0x04, 0x5D, 0x04, 0xF4, 0xED, 
	0xED, 0xF4, 0x04, 0x1F, 0x1F, 0x1F, 0x37, 0x04, 0x5D, 0x04, 0xF4, 0xED, 
	0xED, 0xF4, 0x04, 0x53, 0x1F, 0x1F, 0x1F, 0x04, 0x5D, 0x04, 0xF4, 0xED, 
	0xED, 0xF4, 0x04, 0x53, 0x04, 0xF4, 0xF4, 0x04, 0x5D, 0x04, 0xF4, 0xED, 
	0xED, 0xF4, 0x04, 0x53, 0x04, 0xF4, 0xF4, 0x04, 0x5D, 0x04, 0xF4, 0xED, 
	0xED, 0xF4, 0x04, 0x04, 0x04, 0x04, 0x04, 0x5D, 0x5D, 0x04, 0xF4, 0xED, 
	0xED, 0xF4, 0x04, 0x04, 0x5D, 0x5D, 0x5D, 0x5D, 0x5D, 0x04, 0xF4, 0xED, 
	0xED, 0xF4, 0x04, 0x04, 0x5D, 0x5D, 0x5D, 0xB7, 0x04, 0x04, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x04, 0x53, 0x5D, 0x5D, 0xB7, 0x04, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x04, 0x53, 0x5D, 0x5D, 0xB7, 0x04, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x04, 0x53, 0x5D, 0x5D, 0xB7, 0x04, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x04, 0x53, 0x5D, 0x5D, 0xB7, 0x04, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x04, 0x53, 0x5D, 0x5D, 0xB7, 0x04, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x04, 0x53, 0x5D, 0x5D, 0x5D, 0x04, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x04, 0x53, 0x5D, 0x5D, 0x5D, 0x04, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x04, 0x53, 0x5D, 0x5D, 0x5D, 0x04, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x04, 0x53, 0x5D, 0x5D, 0x5D, 0x04, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x04, 0x53, 0x5D, 0x5D, 0x5D, 0x04, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x04, 0x53, 0x5D, 0x5D, 0x5D, 0x04, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x04, 0x53, 0x53, 0x5D, 0x5D, 0x04, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0xF4, 0xF4, 0xA3, 0x9A, 0xAB, 0xF4, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x9A, 0x00, 0x00, 0x00, 0x00, 0x52, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9A, 0xF4, 0xED, 
	0xED, 0xF4, 0xA3, 0x00, 0x00, 0x12, 0x1B, 0x00, 0x00, 0x00, 0xF4, 0xED, 
	0xED, 0xF4, 0x5A, 0x00, 0x00, 0x1B, 0x3F, 0x12, 0x00, 0x00, 0xF4, 0xED, 
	0xED, 0xF4, 0x49, 0x00, 0x00, 0x2D, 0x3F, 0x09, 0x00, 0x00, 0xF4, 0xED, 
	0xED, 0xF4, 0x00, 0x00, 0x00, 0x37, 0x37, 0x00, 0x00, 0x00, 0xF4, 0xED, 
	0xED, 0xAB, 0x00, 0x00, 0x09, 0x37, 0x25, 0x00, 0x00, 0x51, 0xF4, 0xED, 
	0xED, 0xA3, 0x00, 0x00, 0x13, 0x37, 0x1B, 0x00, 0x00, 0x9A, 0xF4, 0xED, 
	0xED, 0x5A, 0x00, 0x00, 0x24, 0x37, 0x09, 0x00, 0x00, 0xAB, 0xF4, 0xED, 
	0xED, 0x49, 0x00, 0x00, 0x2E, 0x37, 0x00, 0x00, 0x00, 0xF4, 0xF4, 0xED, 
	0xED, 0x00, 0x00, 0x00, 0x37, 0x25, 0x00, 0x00, 0x51, 0xF4, 0xF4, 0xED, 
	0xED, 0x00, 0x00, 0x12, 0x37, 0x1B, 0x00, 0x00, 0x5A, 0xF4, 0xF4, 0xED, 
	0xED, 0x00, 0x00, 0x00, 0x37, 0x12, 0x00, 0x00, 0xA3, 0xF4, 0xF4, 0xED, 
	0xED, 0x49, 0x00, 0x00, 0x13, 0x00, 0x00, 0x00, 0xF4, 0xF4, 0xF4, 0xED, 
	0xED, 0xA3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9A, 0xF4, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0x5A, 0x00, 0x00, 0x00, 0x5A, 0xF4, 0xF4, 0xF4, 0xF4, 0xED, 
	0xED, 0xED, 0xED, 0xA4, 0x9B, 0xA4, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED 

	# imagem do esilingue de prata
	plotEstilinguePrata: .word
	0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 
	0xED, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0x52, 0x52, 0x52, 0xF4, 0xF4, 0x52, 0x52, 0x52, 0xF4, 0xED, 
	0xED, 0xF4, 0x52, 0x5B, 0x52, 0xF4, 0xF4, 0x52, 0xF6, 0x52, 0xF4, 0xED, 
	0xED, 0xF4, 0x52, 0x5B, 0x52, 0xF4, 0xF4, 0x52, 0xF6, 0x52, 0xF4, 0xED, 
	0xED, 0xF4, 0x52, 0xC0, 0xE8, 0xE8, 0xE8, 0x52, 0xA4, 0x52, 0xF4, 0xED, 
	0xED, 0xF4, 0x52, 0xC0, 0xC0, 0xC0, 0xE8, 0x52, 0xA4, 0x52, 0xF4, 0xED, 
	0xED, 0xF4, 0x52, 0x5B, 0xC0, 0xC0, 0xC0, 0x52, 0xA4, 0x52, 0xF4, 0xED, 
	0xED, 0xF4, 0x52, 0x5B, 0x52, 0xF4, 0xF4, 0x52, 0xA4, 0x52, 0xF4, 0xED, 
	0xED, 0xF4, 0x52, 0x5B, 0x52, 0xF4, 0xF4, 0x52, 0xA4, 0x52, 0xF4, 0xED, 
	0xED, 0xF4, 0x52, 0x52, 0x52, 0x52, 0x52, 0xA4, 0xA4, 0x52, 0xF4, 0xED, 
	0xED, 0xF4, 0x52, 0x52, 0xA4, 0xA4, 0xA4, 0xA4, 0xA4, 0x52, 0xF4, 0xED, 
	0xED, 0xF4, 0x52, 0x52, 0xA4, 0xA4, 0xA4, 0xF6, 0x52, 0x52, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x52, 0x5B, 0xA4, 0xA4, 0xF6, 0x52, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x52, 0x5B, 0xA4, 0xA4, 0xF6, 0x52, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x52, 0x5B, 0xA4, 0xA4, 0xF6, 0x52, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x52, 0x5B, 0xA4, 0xA4, 0xF6, 0x52, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x52, 0x5B, 0xA4, 0xA4, 0xF6, 0x52, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x52, 0x5B, 0xA4, 0xA4, 0xA4, 0x52, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x52, 0x5B, 0xA4, 0xA4, 0xA4, 0x52, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x52, 0x5B, 0xA4, 0xA4, 0xA4, 0x52, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x52, 0x5B, 0xA4, 0xA4, 0xA4, 0x52, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x52, 0x5B, 0xA4, 0xA4, 0xA4, 0x52, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x52, 0x5B, 0xA4, 0xA4, 0xA4, 0x52, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x52, 0x5B, 0x5B, 0xA4, 0xA4, 0x52, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x52, 0x52, 0x52, 0x52, 0x52, 0x52, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xAB, 0x09, 0x00, 0x09, 0x52, 0x5A, 0xA3, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9A, 0xED, 
	0xED, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9B, 
	0xED, 0x40, 0x00, 0x12, 0x2E, 0x1B, 0x1C, 0x1C, 0x0A, 0x00, 0x00, 0x49, 
	0xED, 0x00, 0x00, 0x1B, 0x2F, 0x2F, 0x2F, 0x2F, 0x2F, 0x09, 0x00, 0x01, 
	0xED, 0x00, 0x00, 0x13, 0x2F, 0x2F, 0x1C, 0x25, 0x2F, 0x0A, 0x00, 0x01, 
	0xED, 0x40, 0x00, 0x00, 0x25, 0x12, 0x00, 0x1C, 0x2F, 0x00, 0x00, 0x01, 
	0xED, 0xF4, 0x00, 0x00, 0x00, 0x00, 0x0A, 0x2F, 0x09, 0x00, 0x00, 0x4A, 
	0xED, 0xF4, 0x00, 0x00, 0x00, 0x09, 0x2F, 0x0A, 0x00, 0x00, 0x00, 0x9C, 
	0xED, 0xF4, 0x00, 0x00, 0x09, 0x2F, 0x1C, 0x00, 0x00, 0x00, 0x51, 0xED, 
	0xED, 0x40, 0x00, 0x00, 0x26, 0x2F, 0x09, 0x12, 0x00, 0x00, 0x00, 0x9C, 
	0xED, 0x40, 0x00, 0x09, 0x2F, 0x26, 0x0A, 0x2F, 0x1B, 0x00, 0x00, 0x52, 
	0xED, 0x00, 0x00, 0x13, 0x2F, 0x2F, 0x2F, 0x2F, 0x2F, 0x00, 0x00, 0x41, 
	0xED, 0x40, 0x00, 0x12, 0x2F, 0x2F, 0x26, 0x1C, 0x2F, 0x00, 0x00, 0x01, 
	0xED, 0x40, 0x00, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x12, 0x00, 0x00, 0x4A, 
	0xED, 0xF4, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9B, 
	0xED, 0xF4, 0x9A, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00, 0x00, 0x5A, 0xED, 
	0xED, 0xED, 0xED, 0xED, 0xA4, 0xE5, 0xED, 0xE4, 0x9C, 0xE4, 0xED, 0xED, 
 

	# imagem do estilingue Magico Dourado
	plotEstilingueOuro: .word
	0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED, 0xED,
	0xED, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xED,
	0xED, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xED,
	0xED, 0xF4, 0x14, 0x14, 0x14, 0xF4, 0xF4, 0x14, 0x14, 0x14, 0xF4, 0xED, 
	0xED, 0xF4, 0x14, 0x2D, 0x14, 0xF4, 0xF4, 0x14, 0xBE, 0x14, 0xF4, 0xED, 
	0xED, 0xF4, 0x14, 0x2D, 0x14, 0xF4, 0xF4, 0x14, 0xBE, 0x14, 0xF4, 0xED, 
	0xED, 0xF4, 0x14, 0x07, 0x04, 0x04, 0x04, 0x14, 0x3F, 0x14, 0xF4, 0xED, 
	0xED, 0xF4, 0x14, 0x07, 0x07, 0x07, 0x04, 0x14, 0x3F, 0x14, 0xF4, 0xED, 
	0xED, 0xF4, 0x14, 0x2D, 0x07, 0x07, 0x07, 0x14, 0x3F, 0x14, 0xF4, 0xED, 
	0xED, 0xF4, 0x14, 0x2D, 0x14, 0xF4, 0xF4, 0x14, 0x3F, 0x14, 0xF4, 0xED, 
	0xED, 0xF4, 0x14, 0x2D, 0x14, 0xF4, 0xF4, 0x14, 0x3F, 0x14, 0xF4, 0xED, 
	0xED, 0xF4, 0x14, 0x14, 0x14, 0x14, 0x14, 0x3F, 0x3F, 0x14, 0xF4, 0xED, 
	0xED, 0xF4, 0x14, 0x14, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x14, 0xF4, 0xED, 
	0xED, 0xF4, 0x14, 0x14, 0x3F, 0x3F, 0x3F, 0xBE, 0x14, 0x14, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x14, 0x2D, 0x3F, 0x3F, 0xBE, 0x14, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x14, 0x2D, 0x3F, 0x3F, 0xBE, 0x14, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x14, 0x2D, 0x3F, 0x3F, 0xBE, 0x14, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x14, 0x2D, 0x3F, 0x3F, 0xBE, 0x14, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x14, 0x2D, 0x3F, 0x3F, 0xBE, 0x14, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x14, 0x2D, 0x3F, 0x3F, 0x3F, 0x14, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x14, 0x2D, 0x3F, 0x3F, 0x3F, 0x14, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x14, 0x2D, 0x3F, 0x3F, 0x3F, 0x14, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x14, 0x2D, 0x3F, 0x3F, 0x3F, 0x14, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x14, 0x2D, 0x3F, 0x3F, 0x3F, 0x14, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x14, 0x2D, 0x3F, 0x3F, 0x3F, 0x14, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x14, 0x2D, 0x2D, 0x3F, 0x3F, 0x14, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0xF4, 0xF4, 0xED, 
	0xED, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xED,
	0xED, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xED,
	0xED, 0xF4, 0xF4, 0xF4, 0xEC, 0xA3, 0xA3, 0xAC, 0xF4, 0xF4, 0xF4, 0xED,
	0xED, 0xF4, 0xA3, 0x49, 0x00, 0x00, 0x00, 0x00, 0x5A, 0xAC, 0xF4, 0xED,
	0xED, 0x52, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xAB, 0xED,
	0xED, 0x00, 0x00, 0x00, 0x00, 0x0A, 0x13, 0x00, 0x00, 0x00, 0x09, 0xED,
	0xED, 0x00, 0x00, 0x13, 0x27, 0x27, 0x27, 0x1E, 0x00, 0x00, 0x00, 0xA4, 
	0xED, 0x00, 0x00, 0x0B, 0x27, 0x1E, 0x1C, 0x27, 0x13, 0x00, 0x00, 0x9B, 
	0xED, 0x00, 0x00, 0x01, 0x14, 0x00, 0x00, 0x13, 0x13, 0x00, 0x00, 0x93, 
	0xED, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1D, 0x13, 0x00, 0x00, 0x9B, 
	0xED, 0xA3, 0x00, 0x00, 0x00, 0x00, 0x13, 0x1E, 0x00, 0x00, 0x00, 0xA4, 
	0xED, 0xA3, 0x00, 0x00, 0x0A, 0x1E, 0x27, 0x0B, 0x00, 0x00, 0x00, 0x93, 
	0xED, 0xF4, 0x00, 0x00, 0x00, 0x13, 0x1D, 0x27, 0x1D, 0x00, 0x00, 0x4A, 
	0xED, 0xF4, 0x09, 0x00, 0x00, 0x00, 0x00, 0x1E, 0x27, 0x00, 0x00, 0x41, 
	0xED, 0xF4, 0xAB, 0x08, 0x00, 0x00, 0x00, 0x27, 0x14, 0x00, 0x00, 0x52, 
	0xED, 0xF4, 0x09, 0x00, 0x00, 0x01, 0x1E, 0x27, 0x01, 0x00, 0x00, 0x9B, 
	0xED, 0xF4, 0x00, 0x00, 0x00, 0x14, 0x13, 0x00, 0x00, 0x00, 0x08, 0xED,
	0xED, 0xF4, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA3, 0xED,
	0xED, 0xF4, 0xAB, 0x09, 0x00, 0x00, 0x00, 0x00, 0x51, 0xA3, 0xF4, 0xED,
	0xED, 0xED, 0xED, 0xED, 0x9C, 0x93, 0x93, 0xA4, 0xED, 0xED, 0xED, 0xED


	plotWin:	.word

0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0x52, 0x00, 0x00, 0x00, 0xA3, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0x00, 0x00, 0x09, 0x00, 0x00, 0x52, 0XF1, 0XF1, 0XF1, 0XF1, 0x09, 0x00, 0x00, 0x00, 0x00, 0x52, 0xF1, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1,
0x51, 0x00, 0x00, 0x00, 0x08, 0xA8, 0xF0, 0x00, 0x01, 0x0B, 0x00, 0x00, 0xA0, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0xB0, 0x00, 0x09, 0x1F, 0x0B, 0x00, 0x00, 0x50, 0xA8, 0XF1, 0xA8, 0x00, 0x0A, 0x0A, 0x01, 0x00, 0x00, 0x08, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1,
0x00, 0x09, 0x13, 0x0A, 0x00, 0x00, 0xA8, 0x00, 0x0A, 0x27, 0x1C, 0x00, 0x08, 0x58, 0xA0, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0x48, 0x00, 0x1E, 0x1F, 0x1D, 0x00, 0x00, 0x00, 0x08, 0x58, 0x08, 0x00, 0x14, 0x1F, 0x1F, 0x0A, 0x00, 0xA8, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1,
0x00, 0x00, 0x37, 0x37, 0x1C, 0x00, 0x00, 0x00, 0x13, 0x2F, 0x2F, 0x0A, 0x00, 0x00, 0x00, 0x50, 0x00, 0x08, 0x58, 0xB0, 0x58, 0x00, 0x13, 0x27, 0x27, 0x00, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x0B, 0x0A, 0x0A, 0x00, 0x08, 0x00, 0x00, 0x50, 0xA8, 0xA0, 0xF0, 0XF1, 0XF1,
0x51, 0x00, 0x1B, 0x3F, 0x37, 0x13, 0x00, 0x00, 0x25, 0x37, 0x37, 0x09, 0x1B, 0x24, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2F, 0x2F, 0x00, 0x12, 0x2F, 0x25, 0x00, 0x13, 0x13, 0x13, 0x27, 0x26, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA0, 0XF1,
0XF1, 0x00, 0x00, 0x1B, 0x3F, 0x36, 0x00, 0x00, 0x37, 0x3F, 0x24, 0x09, 0x37, 0x3F, 0x1B, 0x00, 0x00, 0x36, 0x1B, 0x00, 0x12, 0x12, 0x00, 0x24, 0x37, 0x09, 0x0A, 0x37, 0x37, 0x09, 0x1B, 0x2F, 0x09, 0x2F, 0x2F, 0x25, 0x00, 0x13, 0x2F, 0x13, 0x0A, 0x13, 0x00, 0x00, 0xA0,
0XF1, 0xA8, 0x00, 0x00, 0x24, 0x3F, 0x36, 0x1B, 0x3F, 0x3F, 0x12, 0x24, 0x3F, 0x36, 0x3F, 0x24, 0x00, 0x1B, 0x3F, 0x12, 0x1B, 0x3F, 0x09, 0x09, 0x3F, 0x24, 0x12, 0x36, 0x37, 0x12, 0x1B, 0x24, 0x00, 0x2D, 0x37, 0x25, 0x00, 0x00, 0x2F, 0x37, 0x2E, 0x37, 0x1C, 0x00, 0X00,
0XF1, 0XF1, 0xA0, 0x00, 0x00, 0x24, 0x3F, 0x3F, 0x3F, 0x36, 0x00, 0x2D, 0x3F, 0x00, 0x00, 0x36, 0x2D, 0x12, 0x3F, 0x12, 0x12, 0x3F, 0x00, 0x00, 0x24, 0x36, 0x12, 0x2D, 0x24, 0x24, 0x1B, 0x00, 0x00, 0x09, 0x3F, 0x1B, 0x00, 0x00, 0x24, 0x3F, 0x09, 0x13, 0x37, 0x13, 0X00,
0XF1, 0XF1, 0XF1, 0xA0, 0x00, 0x00, 0x24, 0x37, 0x37, 0x13, 0x00, 0x13, 0x37, 0x09, 0x00, 0x13, 0x37, 0x12, 0x3F, 0x12, 0x00, 0x3F, 0x00, 0x00, 0x00, 0x37, 0x1B, 0x2D, 0x09, 0x36, 0x1B, 0x00, 0x00, 0x00, 0x3F, 0x12, 0x00, 0x00, 0x12, 0x3F, 0x09, 0x00, 0x2D, 0x1B, 0X00,
0XF1, 0XF1, 0XF1, 0XF1, 0xA0, 0x00, 0x00, 0x26, 0x2F, 0x09, 0x00, 0x00, 0x2E, 0x25, 0x0A, 0x24, 0x37, 0x12, 0x2E, 0x1C, 0x00, 0x37, 0x1B, 0x00, 0x00, 0x1B, 0x2D, 0x36, 0x00, 0x1B, 0x36, 0x09, 0x00, 0x00, 0x2D, 0x2D, 0x00, 0x00, 0x00, 0x37, 0x12, 0x00, 0x3F, 0x1B, 0X00,
0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0x58, 0x00, 0x1C, 0x27, 0x13, 0x00, 0x00, 0x09, 0x1D, 0x2F, 0x2F, 0x26, 0x00, 0x0A, 0x2F, 0x2F, 0x2F, 0x2F, 0x1C, 0x00, 0x00, 0x2E, 0x37, 0x09, 0x00, 0x2F, 0x1B, 0x00, 0x00, 0x1B, 0x37, 0x1B, 0x09, 0x00, 0x2D, 0x2E, 0x00, 0x3F, 0x24, 0X00,
0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0xA0, 0x00, 0x0B, 0x1F, 0x1D, 0x00, 0x50, 0x00, 0x00, 0x01, 0x09, 0x00, 0x00, 0x00, 0x09, 0x1D, 0x14, 0x00, 0x09, 0x00, 0x00, 0x09, 0x26, 0x13, 0x00, 0x00, 0x0A, 0x00, 0x00, 0x09, 0x09, 0x00, 0x00, 0x00, 0x09, 0x24, 0x00, 0x1B, 0x24, 0X00,
0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0xB0, 0x00, 0x00, 0x14, 0x15, 0x00, 0x50, 0x58, 0x50, 0x00, 0x00, 0x08, 0x58, 0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x50, 0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x50, 0x00, 0x00, 0x50, 0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA0,
0xF1, 0XF1, 0XF1, 0XF1, 0XF1, 0XF1, 0x50, 0x00, 0x00, 0x00, 0x00, 0x58, 0XF1, 0XF1, 0xF0, 0xB0, 0XF1, 0XF1, 0XF1, 0xA0, 0x50, 0x58, 0xA8, 0xF0, 0XF1, 0XF1, 0x50, 0x00, 0x00, 0x50, 0xF0, 0xA8, 0XF1, 0XF1, 0xF0, 0xF0, 0XF1, 0XF1, 0xF0, 0xA0, 0x58, 0xA0, 0xA0, 0x58, 0XF1

 	#Imagem da Explosao1
	plotBoom1: .word
 0x000000F1, 0x000000F1, 0x0000003F, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x0000003F,
 0x0000003F, 0x000000F1, 0x0000001F, 0x0000003F, 0x0000003F, 0x000000F1, 0x0000001F, 0x0000003F,
 0x0000003F, 0x0000003F, 0x0000001F, 0x0000001F, 0x0000001F, 0x0000001F, 0x0000001F, 0x000000F1,
 0x000000F1, 0x0000003F, 0x0000003F, 0x00000007, 0x00000007, 0x0000001F, 0x0000001F, 0x000000F1,
 0x000000F1, 0x0000001F, 0x00000007, 0x00000007, 0x00000007, 0x00000007, 0x0000001F, 0x0000003F,
 0x0000003F, 0x0000001F, 0x0000001F, 0x0000001F, 0x00000007, 0x0000001F, 0x0000003F, 0x000000F1,
 0x0000003F, 0x000000F1, 0x0000003F, 0x0000003F, 0x0000003F, 0x0000001F, 0x0000003F, 0x0000003F,
 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x0000001F, 0x0000001F, 0x000000F1, 0x0000003F

 	#Imagem da Explosao2
	plotBoom2: .word
 0x0000003F, 0x000000F1, 0x000000F1, 0x000000F1, 0x000000F1, 0x0000003F, 0x000000F1, 0x000000F1,
 0x0000003F, 0x0000003F, 0x0000003F, 0x0000001F, 0x0000001F, 0x0000001F, 0x0000003F, 0x000000F1,
 0x0000003F, 0x0000001F, 0x0000001F, 0x00000007, 0x0000001F, 0x0000003F, 0x0000003F, 0x0000003F,
 0x000000F1, 0x0000001F, 0x00000007, 0x00000007, 0x00000007, 0x00000007, 0x0000001F, 0x000000F1,
 0x000000F1, 0x0000001F, 0x00000007, 0x00000007, 0x00000007, 0x00000007, 0x0000001F, 0x000000F1,
 0x0000003F, 0x0000001F, 0x0000001F, 0x00000007, 0x00000007, 0x0000001F, 0x0000001F, 0x000000F1,
 0x0000003F, 0x0000003F, 0x0000003F, 0x0000001F, 0x0000001F, 0x0000003F, 0x0000003F, 0x000000F1,
 0x0000003F, 0x000000F1, 0x000000F1, 0x0000003F, 0x000000F1, 0x000000F1, 0x0000003F, 0x0000003F
	
	
	
.text
#===============================================#
#		CODIGO				#
#===============================================#



# ====== ROTINA DE INICIALIZACAO DE FASE ====== #
levelBegin:
	
	# //////////////////////////////// #
	# ================================ #
	# chamada para impressao de fundo  #
	jal imprimeTela
	# ================================ #
	
	
	#Chamada da escolha de estilingue (TODO: implementacao por teclado)
	#Switch/case para escolha (caso 1: leve, caso 2: medio, caso 3: pesado)
	jal escolhaEtg		# Retorna em $f29 a constante elastica
	
	#empilha os pï¿½ssaros a serem usados na fase
	jal empilhaPassaros
	

# ====== LOOP PRINCIPAL DO JOGO ====== #
start:
	mtc1 $zero, $f1					#$f1 = 0
	
	# ========================================================================================== #
	# carrega da memoria o nro de porcos e verifica condicao de vitoria
	la $a0, numPigs
	jal carregaPosicaoAtualVetor
	l.s $f2, 0($v0) 				#carrega nro de porcos da memoria em $f2
	c.eq.s $f1, $f2					#verifica condicao de vitoria (num porcos == 0)
	bc1t vitoria
	# ========================================================================================== #
	
	# ========================================================================================== #
	# carrega da memoria o nro de passaros e verifica a condicao de derrota
	la $a0, numBirds
	jal carregaPosicaoAtualVetor
	l.s $f2, 0($v0)					#carrega nro de passaros da memoria em $f2
	c.eq.s $f1, $f2					#verifica condicao de derrota (num passaros == 0)
	bc1t derrota
	# ========================================================================================== #


	# desempilha o passaro, carregando sua massa
	l.s $f28,0($t9)					#massa do passaro sera armaz. no f28
	addi $t9,$t9,4					#desempilha o passaro

	# //////////////////////////////// #
	# ================================ #
	# chamada para impressao de fundo  #
	jal imprimeTela
	# ================================ #
	
	# ================================ #
	# chamada para impressao de blocos #
	jal imprimeBlocos
	# ================================ #
	
	# ================================ #
	# chamada para impressao de porcos #
	jal imprimePorco
	# ================================ #
	
	# ================================ #
	# chamada para impressao de porcos #
	jal loopImprimeEstilingue
	# ================================ #
	
	# ================================ #
	# chamada para impressao do passaro na posicao inicial
	l.s $f26, xini
	cvt.w.s $f1, $f26
	mfc1 $a0, $f1			# yPassaro no $a0
	l.s $f25, yini
	cvt.w.s $f1, $f25
	mfc1 $a1, $f1			# yPassaro no $a1
	mov.s $f8, $f28			# massa no $f8
	jal imprimePassaro
	# //////////////////////////////// #
	
	
	# ============================================================= #
	# leitura dos deslocamentos e calculos das velocidades iniciais #
		
		# ========================================================================================== #
		# empilhando para chamar loop de input do teclado
		# abre espaï¿½o na pilha e empilha os registradores salvos
		addi $sp, $sp, -16
		sw $ra, 12($sp)
		sw $s0, 8($sp)
		sw $s1, 4($sp)
		sw $s2, 0($sp)
		# ========================================================================================== #
		# zerando os regs $s0 e $s1. $t2 = 100
		move $s0, $zero
		move $s1, $zero
		li $t2, 50
		# ========================================================================================== #
		# chamada da rotina de input do teclado
		# ================================ #
		# chamada para impressao do passaro na posicao inicial
		l.s $f26, xini
		cvt.w.s $f1, $f26
		mfc1 $a0, $f1			# yPassaro no $a0
		l.s $f25, yini
		cvt.w.s $f1, $f25
		mfc1 $a1, $f1			# yPassaro no $a1
		mov.s $f8, $f28			# massa no $f8
		# Seta $t0 com a posicao inicial do passaro
	move $t0, $a1			# $t0 = posicao Y do passaro
	
	move $t1, $a0				# $t1 = posicao X do passaro
	
	sll $t0, $t0, 12			# shifta o Y de 12
	add $t0, $t0, $t1			# adiciona X
	lui $t1, 0x8000				# $t1 = 0x80000000
	or $t0, $t0, $t1			# OR entre 0x80000000 e 0x000YYXXX
	move $a0, $t0				# $a0 = posicao inicial do passaro na forma 0x800YYXXX
	# ========================================================================================== #
	
	# ========================================================================================== #
	#verifica se o passaro e vermelho
	l.s $f1, massaRBird
	c.eq.s $f8, $f1
	bc1t oPassaroeVermelho1
	#verifica se o passaro e azul
	l.s $f1, massaBBird
	c.eq.s $f8, $f1
	bc1t oPassaroeAzul1
	#verifica se o passaro e vermelho
	l.s $f1, massaYBird
	c.eq.s $f8, $f1
	bc1t oPassaroeAmarelo1
	# ========================================================================================== #
	
	# SETA O PASSARO COMO VERMELHO
	oPassaroeVermelho1:
		la $a1, plotRbird
		j inputTecladoLancamento
	# SETA O PASSARO COMO AZUL
	oPassaroeAzul1:
		la $a1, plotBbird
		j inputTecladoLancamento
	# SETA O PASSARO COMO AMARELO
	oPassaroeAmarelo1:
		la $a1, plotYbird
		j inputTecladoLancamento
	
	inputTecladoOK:
	
		# ========================================================================================== #
		
					
		
		# calculo da velociade inicial em X
		mtc1 $v0,$f8 				# $f8 = deslocamento em X
		cvt.s.w $f8, $f8				
		mov.s $f9,$f29				# constante elastico
		mov.s $f10,$f28				# massa do passaro
		jal Velastica				#Calculo da velocidade elastica em x
		mov.s $f31,$f13				#$f31 = v0x
		
		li $t0, -1
		mult $v1, $t0
		mflo $v1				# $v1 = -$v0
		mtc1 $v1,$f8 				# $f8 = deslocamento em Y
		
		# calculo da velociade inicial em Y
		mtc1 $v1,$f8 				# $f8 = deslocamento em X
		cvt.s.w $f8, $f8
		mov.s $f9,$f29				# constante elastico
		mov.s $f10,$f28				# massa do passaro
		jal Velastica				#Calculo da velocidade elastica em y
		mov.s $f30,$f13				#$f30 = v0y
	# ============================================================= #
	
	
	# ========================================================================================== #
	# inicializando as variaveis
	l.s $f26,xini			#$f26 = Posicao X atual
	l.s $f25,yini			#$f25 = Posicao Y atual
	mtc1 $zero,$f27			#$f27 = tempo atual
	l.s $f24,ymax			#$f24 = altura do chï¿½o
	# ========================================================================================== #
	
	# ========================================================================================== #
	# passaro atirado (nroPassaros -1)
	la $a0, numBirds
	jal carregaPosicaoAtualVetor
	l.s $f1, 0($v0)			#carrega nro de passaros da memoria em $f1
	l.s $f2, const1			#$f2 = 1
	sub.s $f1, $f1, $f2		#$f1 = $f1 - $f2
	s.s $f1, 0($v0)			#salva nro de passsaros na memoria
	# ========================================================================================== #


# ====== LOOP DE CHECAGEM DE COLISAO ====== #	
Loop1:  
	
	# ========================================================================================== #
	# verifica se houve colisao com as bordas da tela
	mov.s $f8,$f26			#Carrega os argumentos (posicao do passaro) para checagem de colisao
	mov.s $f9,$f25
	jal rotinaColisaoLimites
	l.s $f1, const1			#$f1 = 1
	c.eq.s $f13, $f1		#Verifica se o passaro passou dos limites da tela
	bc1t start			#Se passou, volta para o inicio
	# ========================================================================================== #	
	
	# ========================================================================================== #
	# verifica se houve colisao com uma parede
	mov.s $f8,$f26			#Carrega os argumentos (posicao do passaro) para checagem de colisao
	mov.s $f9,$f25
	jal rotinaColisaoParede
	l.s $f1, const1			#$f1 = 1
	c.eq.s $f13, $f1		#verifica se houve realmente a colisao com uma parede
	bc1t start			#retorna ao inicio se houve colisao com a parede
	# ========================================================================================== #
	
	# ========================================================================================== #
	# verifica se houve colisao com um porco
	mov.s $f8,$f26			#Carrega os argumentos (posicao do passaro) para checagem de colisao com porco
	mov.s $f9,$f25
	jal rotinaColisaoPorco	
	l.s $f1,const1			#Checa se houve colisao com porco.
	c.eq.s $f13,$f1			#Se nï¿½o houve, pula para naoColisao
	bc1f naoColisao
	# ========================================================================================== #
	
	
	# mostra a mensagem TANGO DOWN
	#la $a0, msgColisao		#tango down
	#li $v0, 4
	#syscall
	
	
	# ========================================================================================== #
	# numeros de porcos -1
	la $a0, numPigs
	jal carregaPosicaoAtualVetor
	l.s $f1, 0($v0)			#carrega nro de porcos da memoria em $f1
	l.s $f2, const1			#$f2 = 1
	sub.s $f1, $f1, $f2		#$f1 = $f1 - $f2
	s.s $f1, 0($v0)			#salva nro de porcos na memoria	
	# ========================================================================================== #
	
	
	#volta ao inicio
	j start	


# ====== ROTINA DE NAO-COLISAO ====== #	
naoColisao:	
	
	# imprime no terminal as informacoes (X, Y, tempo, etc...)
	# mov.s $f8,$f13			#Carrega se teve ou nao colisao para $f8	
	# jal Imprimir
	
	# incrementa o tempo com base na variavel varTempo
	l.s $f1,vartempo
	add.s $f27,$f27,$f1	 	#incremento do tempo
	
	# ========================================================================================== #
	# atualiza a posicao X  do passaro em $f26
	l.s $f8,xini		
	mov.s $f9,$f31
	mov.s $f10,$f27
	jal AtualizaX	
	mov.s $f26,$f13
	# ========================================================================================== #
	
	# ========================================================================================== #
	# atualiza a posicao Y  do passaro em $f25
	l.s $f8,yini
	mov.s $f9,$f30
	mov.s $f10,$f27
	jal AtualizaY
	mov.s $f25,$f13
	# ========================================================================================== #
	
	cvt.w.s $f1, $f26
	mfc1 $a0, $f1			# $a0 = posicao X do Passaro
	cvt.w.s $f1, $f25
	mfc1 $a1, $f1			# $a1 = posicao Y do Passaro
	mov.s $f8, $f28			# $f8 = massa do passaro
	
	# Seta $t0 com a posicao inicial do passaro
	move $t0, $a1			# $t0 = posicao Y do passaro
	
	move $t1, $a0				# $t1 = posicao X do passaro
	
	sll $t0, $t0, 12			# shifta o Y de 12
	add $t0, $t0, $t1			# adiciona X
	lui $t1, 0x8000				# $t1 = 0x80000000
	or $t0, $t0, $t1			# OR entre 0x80000000 e 0x000YYXXX
	move $a0, $t0				# $a0 = posicao inicial do passaro na forma 0x800YYXXX
	
	# ========================================================================================== #
	#verifica se o passaro e vermelho
	l.s $f1, massaRBird
	c.eq.s $f8, $f1
	bc1t oPassaroeVermelho2
	#verifica se o passaro e azul
	l.s $f1, massaBBird
	c.eq.s $f8, $f1
	bc1t oPassaroeAzul2
	#verifica se o passaro e vermelho
	l.s $f1, massaYBird
	c.eq.s $f8, $f1
	bc1t oPassaroeAmarelo2
	# ========================================================================================== #
	
	# SETA O PASSARO COMO VERMELHO
	oPassaroeVermelho2:
		la $a1, plotRbird
		j naoColisaoContinua
	# SETA O PASSARO COMO AZUL
	oPassaroeAzul2:
		la $a1, plotBbird
		j naoColisaoContinua
	# SETA O PASSARO COMO AMARELO
	oPassaroeAmarelo2:
		la $a1, plotYbird
		j naoColisaoContinua
		
	naoColisaoContinua:
	# ========================================================================================== #
	jal loopImprimePassaro
	
	# volta para o loop de checagem de colisao
	j Loop1
	
	
# ====== ROTINA DE CHECAGEM DE COLISAO COM PAREDES ====== #
# ====== ARGS:	$f8 = xPassaro
# ======	$f9 = yPassaro
rotinaColisaoParede:	
	
	#zero no CoProcessor1
	mtc1 $zero, $f13
	
	# ========================================================================================== #
	# abre espaï¿½o na pilha e empilha os registradores salvos
	addi $sp,$sp,-36					#Abre espaï¿½o na pilha
	sw $ra,32($sp)						#Guarda o retorno
	sw $s0,28($sp)						#Guarda registradores salvos
	sw $s1,24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	s.s $f24, 8($sp)
	s.s $f25, 4($sp)
	s.s $f26, 0($sp)
	# ========================================================================================== #
	
	# ========================================================================================== #
	# carrega da memoria as informacoes das paredes
	la $s0, paredesX	
	la $s1, paredesY 
	la $s2, paredesExpandX
	la $s3, paredesExpandY
	la $s4, numParedes
	# ========================================================================================== #
	
	# ========================================================================================== #
	# Carregando valores de paredes da fase atual	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	move $a0,$s0
	jal carregaPosicaoAtualMatriz
	move $s0, $v0
	
	move $a0, $s1
	jal carregaPosicaoAtualMatriz
	move $s1, $v0
	
	move $a0, $s2
	jal carregaPosicaoAtualMatriz
	move $s2, $v0
	
	move $a0, $s3
	jal carregaPosicaoAtualMatriz
	move $s3, $v0
	
	move $a0, $s4			# $f24 recebe o nï¿½mero de paredes da fase atual.
	jal carregaPosicaoAtualVetor
	l.s $f24, 0($v0)
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	# ========================================================================================== #
	
	# Guarda as posiï¿½ï¿½es do pï¿½ssaro nos registradores salvos para conservaï¿½ï¿½o
	mov.s $f25, $f8		
	mov.s $f26, $f9


# ====== LOOP PARA CHECAR A COLISAO COM TODAS AS PAREDES DA FASE ====== #
loopRotinaColisao:

	# Carrega as posiï¿½ï¿½es do pï¿½ssaro para checagem de colisao
	mov.s $f8, $f25		
	mov.s $f9, $f26

	# verifica se ainda existem paredes a serem checadas
	mtc1 $zero, $f2			# $f2 = 0
	c.eq.s $f24, $f2	
	bc1t fimLoopRotinaColisao

	# ========================================================================================== #
	# carrega as posicoes e expansoes da parede a ser checada
	l.s $f10, 0($s0)		# carrega em $f10 a posiï¿½ï¿½o x da parede
	l.s $f11, 0($s1)		# carrega em $f11 a posiï¿½ï¿½o y da parede
	l.s $f1, 0($s2)			# carrega o valor da expansao X da posiï¿½ï¿½o atual do vetor
	l.s $f2, 0($s3) 		# carrega o valor da expansao Y da posiï¿½ï¿½o atual do vetor
	addi $sp, $sp, -8		# empilhando os Expands para a rotina checaColisaoParede
	s.s $f1, 0($sp)
	s.s $f2, 4($sp)	
	# ========================================================================================== #
	
	# verifica se houve colisao com a parede
	jal checaColisaoParede
	
	# ========================================================================================== #
	# verifica se realmente houve colisao
	l.s $f1, const1			# $f1 = 1.0
	c.eq.s $f13, $f1		# verifica se a funï¿½ï¿½o retornou 1
	bc1t fimLoopRotinaColisao
	# ========================================================================================== #
	
	# ========================================================================================== #
	# avanca para a proxima parede
	addi $s0, $s0, 4		# avanca para a proxima posicao dos vetores
	addi $s1, $s1, 4
	addi $s2, $s2, 4
	addi $s3, $s3, 4
	sub.s $f24, $f24, $f1		# nro paredes -1
	# ========================================================================================== #
	
	
	# volta para o inicio do loop
	j loopRotinaColisao


# ======= TODAS AS PAREDES FORAM VERIFICADAS E NAO HA COLISAO COM ELAS ====== #
fimLoopRotinaColisao:
	
	# ========================================================================================== #		
	# desempilha os registradores salvos e abre espaco na pilha
	lw $ra, 32($sp)
	lw $s0, 28($sp)		
	lw $s1, 24($sp)
	lw $s2, 20($sp)
	lw $s3, 16($sp)
	lw $s4, 12($sp)
	l.s $f24, 8($sp)
	l.s $f25, 4($sp)
	l.s $f26, 0($sp)	
	addi $sp,$sp, 36		#Abre espaï¿½o na pilha
	# ========================================================================================== #
	
	
	# volta a rotina anterior
	jr $ra
	
# ====== CHECA A COLISAO COM UMA DADA PAREDE ====== #
# ====== ARGS:	$f8  = xPassaro
# ======	$f9  = yPassaro
# ======	$f10 = xParede
# ======	$f11 = yParede
# ======	empilhados = ExpandsXY
# ====== RETS:	1 caso nï¿½o houve colisao
# ======	0 caso houve colisao											
checaColisaoParede:	

	# ========================================================================================== #
	# adiciona offset ao XY do passaro
		# empilhamento de retorno de funcao - quick 'n dirty
		addi $sp, $sp, -4	
		sw $ra, 0($sp)
		# addiciona offset ao XY do passaro
		jal conversao
		lw $ra, 0($sp)		#desempilha o retorno
		addi $sp, $sp, 4	
		# retorno da rotina de conversï¿½o de posiï¿½ï¿½o
		mov.s $f8, $f13	
		mov.s $f9, $f14	
	# ========================================================================================== #
	
	# $f13 = 0
	mtc1 $zero, $f13	
	
	# $f3 = offset
	l.s $f3, offset 	
	
	# ========================================================================================== #
	# carrega os ExpandsXY em $f1 e $f2
	l.s $f1, 0($sp)			#carrega o valor da expansao X da posiï¿½ï¿½o atual do vetor
	l.s $f2, 4($sp)			#carrega o valor da expansao Y da posiï¿½ï¿½o atual do vetor
	addi $sp, $sp, 8		#desempilha os valores dos Expands
	# ========================================================================================== #
	
	# ========================================================================================== #
	# operacoes com offsets e expands
	l.s $f4, const1			# $f4 = 1.0
	add.s $f3, $f3, $f4		# offset + 1	
	add.s $f1, $f1, $f4		# expancaoX + 1
	add.s $f2, $f2, $f4		# expancaoY + 1
	mul.s $f1, $f3, $f1		# (expancaoX + 1) x (offset + 1)
	mul.s $f2, $f3, $f2		# (expancaoY + 1) x (offset + 1)
	add.s $f1, $f1, $f10		# ((expancaoX + 1) x (offset + 1)) + (XParede)
	add.s $f2, $f2, $f11		# ((expancaoY + 1) x (offset + 1)) + (YParede)
	# ========================================================================================== #
	
	# ========================================================================================== #
	# comparacoes para checagem de colisao
	c.le.s $f10, $f8	#compara se XParede menor igual XPassaro
	bc1f finalColisaoParede	#se for falso, Nao houve colisao
	
	c.le.s $f8, $f1		#compara se se XPassaro menor igual que ((expancaoX + 1) x (offset + 1)) + (XParede)
	bc1f finalColisaoParede	#se for falso, Nao houve colisao	

	c.le.s $f11, $f9	#compara se YParede menor igual que YPassaro
	bc1f finalColisaoParede	#se for falso, Nao houve colisao
	
	c.le.s $f9, $f2		#comparase se YPassaro menor igual que ((expancaoY + 1) x (offset + 1)) + (YParede)
	bc1f finalColisaoParede	#se for falso, Nao houve colisao
	# ========================================================================================== #
	
	# ////////////////////// #
	# imprimir explosao do passaro #
	# Seta $t0 com a posicao inicial do passaro
	cvt.w.s $f1, $f9
	mfc1 $t0, $f1				# $t0 = posicao Y do passaro
	subi $t0, $t0, 6
	
	cvt.w.s $f1, $f8
	mfc1 $t1, $f1				# $t1 = posicao X do passaro
	subi $t1, $t1, 6
		
	sll $t0, $t0, 12			# shifta o Y de 12
	add $t0, $t0, $t1			# adiciona X
	lui $t1, 0x8000				# $t1 = 0x80000000
	or $t0, $t0, $t1			# OR entre 0x80000000 e 0x000YYXXX
	move $a0, $t0				# $a0 = posicao inicial do passaro na forma 0x800YYXXX
	la $a1, plotBoom1			# $a1 = matriz cores boom1
	la $a2, plotBoom2			# $a2 = matriz cores boom2
	
	# empilhamento de retorno de funcao - quick 'n dirty
	addi $sp, $sp, -4	
	sw $ra, 0($sp)
	jal loopImprimeExplosao		# chama a rotina para imprimir a explosÃ£Ã£Ã£Ã£Ã£Ã£o
	lw $ra, 0($sp)		#desempilha o retorno
	addi $sp, $sp, 4	
	
	# ////////////////////// #
	
	
	# retorno ($f13) = 1
	l.s $f13, const1

# ====== RETORNO A ROTINA ANTERIOR ====== #
finalColisaoParede:
	jr $ra


# ====== ROTINA QUE VERIFICA SE O PASSARO ESTA NOS LIMITES DA TELA ====== #
# ====== ARGS:	$f8  = xPassaro
# ======	$f9  = yPassaro
# ====== RETS:	1 caso nï¿½o esteja nos limites
# ======	0 caso esteja nos limites	
rotinaColisaoLimites:
	
	# ========================================================================================== #
	# verifica colisao com o limite superior (parte de cima da tela)
	l.s $f1, ymin		
	c.le.s $f9, $f1		#Ymin (parte de cima da tela) <= yPassaro?
	bc1t passouDosLimites	
	# ========================================================================================== #
	
	# pixel a ser analisado : Inferior direito
	# ========================================================================================== #
	# adiciona offset ao XY do passaro
		# empilhamento de retorno de funcao - quick 'n dirty
		addi $sp, $sp, -4	
		sw $ra, 0($sp)
		# addiciona offset ao XY do passaro
		jal conversao
		# desempilhamento de retorno de funcao
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		# retorno da rotina de conversï¿½o de posiï¿½ï¿½o
		mov.s $f8, $f13	
		mov.s $f9, $f14	
	# ========================================================================================== #
	
	
	# retorno = 0
	mtc1 $zero, $f13
	
	# ========================================================================================== #
	# Checa colisï¿½o com o limite inferior.
	l.s $f1, ymax		
	c.le.s $f1, $f9		#yMax (chao) <= yPassaro?
	bc1t passouDosLimites	
	# ========================================================================================== #
	
	# ========================================================================================== #
	# Checa colisï¿½o com a parte direita da tela
	l.s $f1, xmax		
	c.le.s $f1, $f8		#xMax (parte da direita da tela) <= xPassaro?
	bc1t passouDosLimites	
	# ========================================================================================== #
	
	# retorna ï¿½ rotina anterior
	jr $ra

# ====== RETORNA 1 A ROTINA ANTERIOR ====== #
passouDosLimites:
	# retorno = 1
	l.s $f13, const1
	jr $ra


# ====== PRINTA OS PONTOS NO TERMINAL E ENCERRA O PROGRAMA ====== #
finalLoop:  	
	# $f1 = 0
	mtc1 $zero, $f1

	la $t0, pontosFase
	li $t1, 3		#t1 = 3
	
# ====== LOOP PARA PRINTAR OS PONTOS NO FINAL ====== 
loopPontosFinal:

	# ========================================================================================== #
	# soma os pontos das fases
	l.s $f2, 0($t0)				# $f2 = nro de pontos da fase atual	
	add.s $f1, $f1, $f2			# soma os pontos da fase	
	addi $t0, $t0, 4			# proxima fase	
	addi $t1, $t1, -1			# nro de fases restantes -1	
	bnez $t1, loopPontosFinal		# nro de fases restantes != 0 -> volta para o loop de somar os pontos
	# ========================================================================================== #
		
	# ========================================================================================== #
	
	
# ====== CALCULA A VELOCIDADE ELASTICA ====== #
# ====== ARGS:	$f8  = deslocamento do elastico
# ======	$f9  = constante K do elastico
# ====== 	$f10 = massa do passaro
Velastica:
	# ========================================================================================== #
	# d*sqrt(k/m)
	div.s $f1,$f9,$f10
	sqrt.s $f1,$f1
	mul.s $f13,$f8,$f1
	jr $ra
	# ========================================================================================== #
	
	
# ====== ATUALIZA O X ====== #
# ====== ARGS:	$f8  = xIni
# ======	$f9  = v0x
# ====== 	$f10 = tempoAtual
AtualizaX:
	# ========================================================================================== #
	# xIni + v0x*tempoAtual
	mul.s $f1,$f9,$f10 #v0x . tempoAtual
	add.s $f13,$f1,$f8 #Soma resultado acima com Xinicial
	jr $ra
	# ========================================================================================== #
	
# ====== ATUALIZA O Y ====== #
# ====== ARGS:	$f8  = yIni
# ======	$f9  = v0y
# ====== 	$f10 = tempoAtual
AtualizaY:	
	# ========================================================================================== #
	# yIni + v0y*t + g*t^2
	mul.s $f1,$f10,$f10 #t.t
	l.s $f2,gravity
	mul.s $f1,$f1,$f2 #g.t.t
	l.s $f2,const2
	div.s $f1,$f1,$f2 #g.t.t/2
	mul.s $f2,$f9,$f10 #v0y.t
	add.s $f1,$f1,$f2 #v0y.t+g.t.t/2
	add.s $f13,$f1,$f8 #v0y.t+g.t.t/2 + y0
	jr $ra
	# ========================================================================================== #
	
	
# ====== ROTINA QUE VERIFICA SE A AVE COLIDIU COM O SUINO (wtf?) ====== #
# ====== ARGS:	$f8  = xPassaro
# ======	$f9  = yPassaro
# ====== 	$f10 = xPorco
# ======	$f11 = yPorco
colisaoPorco:	
	
	# ========================================================================================== #
	# adiciona offset ao XY do passaro
		# empilhamento de retorno de funcao - quick 'n dirty
		addi $sp, $sp, -4	
		sw $ra, 0($sp)
		# addiciona offset ao XY do passaro
		jal conversao
		# desempilhamento de retorno de funcao
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		# retorno da rotina de conversï¿½o de posiï¿½ï¿½o
		mov.s $f8, $f13	
		mov.s $f9, $f14	
	# ========================================================================================== #

	#retorno = 0
	mtc1 $zero, $f13
	
	#$f1 = offset
	l.s $f1,offset
	
	# ========================================================================================== #
	# $f1 = 2offset+1
	add.s $f1,$f1,$f1	# $f1 = offset*2
	l.s $f2,const1		# $f2 = 1
	add.s $f1,$f1,$f2	# $f1 = (offset*2)+1
	# ========================================================================================== #
	
	# ========================================================================================== #
	# comparacoes para checagem de colisao
	c.le.s $f10,$f8		# Verifica se xPorco <= xPassaro
	bc1f fimColisaoPorco
	
	add.s $f2,$f10,$f1	# $f2 = xPorco + ((2*offset)+1)
	c.lt.s $f8,$f2		# Verifica se xPassaro <= xPorco + ((2*offset)+1)
	bc1f fimColisaoPorco
	
	c.le.s $f11,$f9		# Verifica se yPorco <= yPassaro
	bc1f fimColisaoPorco
	
	add.s $f2,$f11,$f1	# $f2 = yPorco + ((2*offset)+1)
	c.lt.s $f9,$f2		#Verifica se YPassaro <= yPorco + ((2*offset)+1)
	bc1f fimColisaoPorco
	# ========================================================================================== #
	
	# retorno ($f13) = 1
	l.s $f13, const1
	
# ====== RETORNO ï¿½ ROTINA ANTERIOR ====== #
fimColisaoPorco:
	jr $ra

# ====== ROTINA QUE VERIFICA SE HOUVE COLISAO PARA TODOS OS PORCOS ====== #
# ====== ARGS:	$f8  = xPassaro
# ======	$f9  = yPassaro
rotinaColisaoPorco:		

	#retorno = 0
	mtc1 $zero, $f13
	
	# ========================================================================================== #
	# abre espaï¿½o na pilha e empilha os registradores salvos
	addi $sp,$sp, -32	
	sw $ra,28($sp)		
	sw $s0,24($sp)
	sw $s1,20($sp)
	sw $s2,16($sp)
	sw $s3,12($sp)	
	s.s $f24, 8($sp)
	s.s $f25, 4($sp)
	s.s $f26, 0($sp)
	# ========================================================================================== #
	
	# ========================================================================================== #
	# Guarda nos registradores salvos as posiï¿½ï¿½es do pï¿½ssaro para conservaï¿½ï¿½o
	mov.s $f25, $f8		
	mov.s $f26, $f9
	# ========================================================================================== #
	
	# ========================================================================================== #
	# carregando da memï¿½ria as informaï¿½ï¿½es dos porcos
	la $s0, pigXPos		
	la $s1, pigYPos
	la $s2, pigExiste	
	la $s3, numPigs		
	# ========================================================================================== #
	
	# ========================================================================================== #
	# Carregando valores dos porcos da fase atual
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	move $a0, $s0
	jal carregaPosicaoAtualMatriz
	move $s0, $v0
	
	move $a0, $s1
	jal carregaPosicaoAtualMatriz
	move $s1, $v0
	
	move $a0, $s2
	jal carregaPosicaoAtualMatriz
	move $s2, $v0
	
	move $a0, $s3
	jal carregaPosicaoAtualVetor
	move $s3, $v0
	
	l.s $f24, 0($s3)	#$f24 recebe o nï¿½mero de porcos ainda vivos da fase atual
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	# ========================================================================================== #
	
	
# ====== LOOP PARA CHECAR A COLISAO COM TODAS OS PORCOS DA FASE ====== #
loopRotinaColisaoPorco:

	# ========================================================================================== #
	# carrega dos registradores salvos a posicao dos passsaros
	mov.s $f8, $f25		
	mov.s $f9, $f26
	# ========================================================================================== #
		
	# ========================================================================================== #
	# verifica se ainda existem porcos a serem verificados			
	mtc1 $zero, $f2		#$f2 = 0
	c.eq.s $f24, $f2	
	bc1t fimLoopRotinaColisaoPorco
	# ========================================================================================== #
	
	
	# ========================================================================================== #
	# carrega as informaï¿½ï¿½es do porco atual na memï¿½ria
	l.s $f10, 0($s0)	#Carrega da memï¿½ria as posiï¿½ï¿½es do porco nos registradores de argumento de funï¿½ï¿½o
	l.s $f11, 0($s1)
	l.s $f1, 0($s2)		#Carrega o estado de existï¿½ncia do porco atual
	c.eq.s $f2, $f1		#E checa se o porco nï¿½o existe
	bc1t proximoPorco
	l.s $f1, const1		#$f1 = 1
	sub.s $f24, $f24, $f1	#Se o porco existir, retira 1 do nï¿½mero de porcos a serem analisados
	# ========================================================================================== #
	
	# verifica se houve colisao com o porco
	jal colisaoPorco
	
	# ========================================================================================== #
	# verifica se realmente houve colisao
	l.s $f1, const1		#$f1 = 1
	c.eq.s $f1, $f13	#verifica se a funcao retornou 1
	bc1t destroiPorco
	# ========================================================================================== #
	
# ====== AVANCA PARA O PROXIMO PORCO ====== #
proximoPorco:
	#avanï¿½a para a proxima posicao do vetor
	addi $s0, $s0, 4					
	addi $s1, $s1, 4
	addi $s2, $s2, 4
	
	j loopRotinaColisaoPorco
	
# ====== ROTINA QUE ELIMINA O MALIGNO PORCO DA FACE DA TERRA ====== #
destroiPorco:
	#setando o pigExiste do porco para zero
	mtc1 $zero, $f1		
	s.s $f1, 0($s2)	
	
	# ========================================================================================== #
	addi $sp, $sp, -4	
	sw $ra, 0($sp)		#empilha o retorno
	jal atribuiPontosPorco	#adiciona os pontos por ter destruido o porco
	
	# imprimir explosao do porco #
	# Seta $t0 com a posicao inicial do porco
	cvt.w.s $f1, $f11
	mfc1 $t0, $f1				# $t0 = posicao Y do passaro
	
	cvt.w.s $f1, $f10
	mfc1 $t1, $f1				# $t1 = posicao X do passaro
	
	sll $t0, $t0, 12			# shifta o Y de 12
	add $t0, $t0, $t1			# adiciona X
	lui $t1, 0x8000			# $t1 = 0x80000000
	or $t0, $t0, $t1			# OR entre 0x80000000 e 0x000YYXXX
	move $a0, $t0				# $a0 = posicao inicial do passaro na forma 0x800YYXXX
	la $a1, plotBoom1			# $a1 = matriz cores boom1
	la $a2, plotBoom2			# $a2 = matriz cores boom2
	
	jal loopImprimeExplosao		# chama a rotina para imprimir a explosÃ£Ã£Ã£Ã£Ã£Ã£o
	
	lw $ra, 0($sp)		#desempilha o retorno
	addi $sp, $sp, 4	
	# ========================================================================================== #
	
	j fimLoopRotinaColisaoPorco
	
# ======= ROTINA QUE ATRIBUI OS PONTOS POR TER DESTRUIDO O PORCO ====== #
atribuiPontosPorco:
	
	# empilha o retorno	
	addi $sp, $sp, -4	
	sw $ra, 0($sp)			
				
	la $a0, pontosFase
	jal carregaPosicaoAtualVetor
	
	# desempilha o retorno
	lw $ra, 0($sp)		
	addi $sp, $sp, 4	

	# $f1 = nro de pontos da fase atual
	l.s $f1, 0($v0)		
	
	# ========================================================================================== #
	# pontos da fase atual + 5000
	l.s $f2, pontosPorco	#$f2 = 5000
	add.s $f2, $f2, $f1	#f2 = pontos da fase atual + 5000
	s.s $f2, 0($v0)		#salva a pontuaï¿½ï¿½o na memoria
	# ========================================================================================== #
	
	#retorna ï¿½ rotina anterior
	jr $ra
	
# ====== TODOS OS PORCOS FORAM VERIFICADOS ====== #
fimLoopRotinaColisaoPorco:
	
	# ========================================================================================== #		
	# desempilha os registradores salvos e abre espaco na pilha
	lw $ra,28($sp)
	lw $s0,24($sp)
	lw $s1,20($sp)
	lw $s2,16($sp)
	lw $s3,12($sp)	
	l.s $f24, 8($sp)
	l.s $f25, 4($sp)
	l.s $f26, 0($sp)	
	addi $sp,$sp, 32	#Abre espaï¿½o na pilha
	# ========================================================================================== #

	# volta a rotina anterior
	jr $ra

# ====== ROTINA DE TRATAMENTO DE VITORIA DE UMA FASE ====== #	
vitoria:
	#atribuiï¿½ï¿½o de pontos para passaros nï¿½o utilizados
	jal atribuirPontosPassaros

	# ========================================================================================== #
	la $a0, pontosFase
	jal carregaPosicaoAtualVetor
	
	l.s $f1, 0($v0)
	cvt.w.s $f2, $f1
	mfc1 $a0, $f2
	
	jal ImprimeLCD			#imprime pontuacao da fase no LCD
	# ========================================================================================== #
	
	# Incrementa a fase atual (passa para a prï¿½xima)
	lw $t0, faseAtual	
	addi $t0, $t0, 1
	
	# Caso a fase atual seja igual a 3 (ultima fase), pula para gameClear
	lw $t1, numFases
	beq $t0, $t1, gameClear	
	
	# salva na memoria a faseAtual incrementada
	sw $t0, faseAtual
	
	#pula para o comeï¿½o da proxima fase
	j levelBegin	
	
# ====== JOGO ZERADO! ====== #
gameClear:
	jal somaPontosFases
	move $a0, $v0
	jal ImprimeLCD
	jal imprimeTela
	li $a0, 0x8006208A
	la $a1, plotWin
	jal imprimeWin			
	j finalLoop

somaPontosFases:

	li $t0, 0				#Contador do loop for
	mtc1 $zero, $f2				#Acumulador de pontos, a ser retornado
	lw $t1, numFases
	la $t2, pontosFase
	
	forLoop:
		beq $t0, $t1, fimForLoop	# loop para somar os pontos de todas as fases para serem somados no final
		
		l.s $f1, 0($t2)			#$t4 = carregador de pontos de fases individuais
		
		add.s $f2, $f2, $f1		#Acumulador += pontos individuais
		
		addi $t2, $t2, 4		#Passa para a próxima fase
		addi $t0, $t0, 1
		j forLoop
		
	fimForLoop:
		
		cvt.w.s $f2, $f2
		
		mfc1 $v0, $f2		#Valor retornado = pontos acumulados
		
		jr $ra
		
		
	
# ====== ATRIBUI PONTOS BASEADOSNO NRO DE PASSAROS RESTANTES ====== #
atribuirPontosPassaros:		
	
	# ========================================================================================== #
	# $f1 = nro de passaros
	addi $sp, $sp, -4	#empilha o retorno
	sw $ra, 0($sp)
	la $a0, numBirds	#carrega em $a0 o nro de passaros
	jal carregaPosicaoAtualVetor	
	l.s $f1, 0($v0)		#f1 = nro de passaros da fase atual
	# ========================================================================================== #
	
	# ========================================================================================== #
	# $f2 = nro de pontos da fase atual
	la $a0, pontosFase
	jal carregaPosicaoAtualVetor	
	l.s $f2, 0($v0)		#$f2 = nro de pontos da fase atual
	lw $ra, 0($sp)		#desempilha
	addi $sp, $sp, 4
	# ========================================================================================== #
	
	# ========================================================================================== #
	# Pontos da Fase Atual + 10000 * nro de Passaros
	l.s $f3, pontosPassaro	#$f3 = 10000
	mul.s $f3, $f3, $f1	#f3 = f3*f1 == nro de passaros * 10000
	add.s $f3, $f3, $f2	#f3 = (nro de passsaros * 10000) + pontos da fase atual
	s.s $f3, 0($v0)		#salva a pontuacao na memoria
	# ========================================================================================== #
	
	jr $ra		


# ====== OS PASSAROS FORAM DERROTADOS. O MUNDO ESTA PERDIDO ====== #
derrota:
	j finalLoop
	
# ====== ROTINA QUE CONVERTE COORDENADA -> COORDENADA + OFFSET
# ====== ARGS:	$f8 = xPassaro
# ======	$f9 = yPassaro
conversao:			
	l.s $f1, offset		#carrega o offset em f1
	add.s $f13, $f8, $f1	#$f13 = $f8 + offset
	add.s $f14, $f9, $f1	#$f14 = $f9 + offset
	
	jr $ra

# ====== ROTINA QUE CALCULA A POSICAO ATUAL A SER USADA PELA MATRIX ====== #
# ====== ARGS:	$a0 = endereï¿½o da matrix
carregaPosicaoAtualMatriz:	

	lw $t1, faseAtual
	lw $t2, wordSize
	lw $t3, maxElemLinha
	mult $t1, $t2	#faseAtual * wordSize
	mflo $v0
	mult $v0, $t3	#(faseAtual * wordSize) * maxElemLinha
	mflo $v0
	add $v0, $a0, $v0	#((faseAtual * wordSize) * maxElemLinha) + endereï¿½o
	
	jr $ra
	
	
# ====== ROTINA QUE CALCULA A POSICAO ATUAL A SER USADA PELO VETOR ====== #
# ====== ARGS:	$a0 = endereï¿½o da vetor	
carregaPosicaoAtualVetor:	

	lw $t1, faseAtual
	lw $t2, wordSize
	mult $t1, $t2	#faseAtual * wordSize
	mflo $v0
	add $v0, $v0, $a0	#endereï¿½o + (faseAtual * wordSize)
	
	jr $ra

# ====== ROTINA QUE PREPARA OS PASSAROS A SEREM USADOS NA FASE ATUAL
empilhaPassaros:		
	
	#empilha o retorno atual
	addi $sp, $sp, -4
	sw $ra, 0($sp)		
	
	#verifica o nro de passaros da fase atual e os salva em f1
	la $a0, numBirds		
	jal carregaPosicaoAtualVetor	
	l.s $f1, 0($v0)
	
	
	#carrega em v0 a posiï¿½ï¿½o atual da matriz de passaros
	la $v0, birds			
	jal carregaPosicaoAtualMatriz
	
	#desempilha o retorno
	lw $ra, 0($sp)
	addi $sp, $sp, 4	
	
	l.s $f2, const1		#f2 = 1
	mtc1 $zero, $f3		#f3 = 0
	
	
# ====== LOOP PARA EMPILHAR OS PASSAROS DA FASE ATUAL ====== #
loopEmpilhaPassaros:	
	
	#if numBirds == 0 -> todos os passaros foram empilhados
	c.eq.s $f1, $f3		
	bc1t passarosEmpilhados	
	
	l.s $f4, 0($v0)		#f4 = passaro atual
	
	addi $sp, $sp, -4	#abre espaï¿½o na pilha
	s.s  $f4, 0($sp)	#salva o passaro atual na pilha
	addi $v0, $v0, 4	#move para o proximo passaro na matrix
	sub.s $f1, $f1, $f2	#numBirds--
	j loopEmpilhaPassaros
	
# ====== TODOS OS PASSAROS FORAM EMPILHADOS ====== #
passarosEmpilhados:
	move $t9, $sp
	jr $ra
	
	
# ================================================ #
#	 FUNCOES DE PLOTAGEM/CONTROLE TECLADO	   #
# ================================================ #

# ====== ROTINA QUE IMPRIME UMA NOVA TELA ====== #
# ====== ARGS:	$a0 = xPassaro
# ======	$a1 = yPassaro
imprimeTela:

	# ========================================================================================== #
	# armazena o $ra na pilha
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	# ========================================================================================== #
	
	# ========================================================================================== #
	#move $s0, $a0			# $s0 = xPassaro
	#move $s1, $a1			# $s1 = yPassaro
	# ========================================================================================== #
	
	# ========================================================================================== #
	la $a0, 0x80000000		# armazena em $a0 a posicao inicial da tela
	la $a1, 0x800D0000		# armazena em $a1 a posicao final do ceu
	li $a2, 0x000000F1		# armazena em $a2 a cor do ceu
	# ========================================================================================== #
	
	# chama a rotina de imprimir o ceu
	jal loopImprimeFundo
	
	# ========================================================================================== #
	la $a0, 0x800D0000		# armazena em $a0 a posicao inicial do chao
	la $a1, 0x800EF140		# armazena em $a1 a posicao final da tela
	li $a2, 0x00000020		# armazena em $a2 a cor do chao
	# ========================================================================================== #
	
	# chama a rotina de imprimir o ceu
	jal loopImprimeChao
	
	# ========================================================================================== #
	# desempilha o $ra
	lw $ra, 0($sp)
	addi $sp, $sp, 4	
	# ========================================================================================== #
	
	#retorna ï¿½ rotina anterior
	jr $ra
	
	
	
# ====== LOOP QUE IMPRIME O FUNDO ====== #
# ====== ARGS:	$a0 = posicao atual da tela
# ======	$a1 = posicao final do ceu
# ======	$a2 = cor do ceu
loopImprimeFundo:
	# ========================================================================================== #
	beq $a0, $a1, fimLoop		#sai do loop caso tenha chegado ao fim do ceu
	sw $a2, 0($a0)			#plota o pixel na tela
	addi $a0, $a0, 1		#avanï¿½a 1 pixel na posicao atual da tela
	j loopImprimeFundo
	# ========================================================================================== #
	
	
# ====== LOOP QUE IMPRIME O FUNDO ====== #
# ====== ARGS:	$a0 = posicao atual da tela
# ======	$a1 = posicao final do chao
# ======	$a2 = cor do chao
    loopImprimeChao:
            # ========================================================================================== #
            li $t1,0				#contador para a cada 5 pixels imprime um mais claro
	loopImprimeChao1:
            beq $a0, $a1, fimLoop           #sai do loop caso tenha chegado ao fim do chao
            beq $t1, 51, semiLoopChao
            sw $a2, 0($a0)                  #plota o pixel na tela
            addi $a0, $a0, 1                #avanï¿½a 1 pixel na posicao atual da tela
            addi $t1,$t1,1
            j loopImprimeChao1
	semiLoopChao:
            addi $t2,$zero,0x59
            sw $t2, 0($a0)
            addi $a0, $a0, 1
            addi $t2,$zero,0x69
            sw $t2, 0($a0)
            addi $a0, $a0, 1
            addi $t2,$zero,0x69
            sw $t2, 0($a0)
            addi $a0, $a0, 1
            addi $t2,$zero,0x69
            sw $t2, 0($a0)
            addi $a0, $a0, 1
            li $t1,0
            j loopImprimeChao1
            # ========================================================================================== #




# ====== ROTINA QUE IMPRIME OS BLOCOS NA TELA ====== #
imprimeBlocos:
	
	# ========================================================================================== #
	# abre espaï¿½o na pilha e empilha os registradores salvos
	addi $sp, $sp, -28
	sw $ra, 24($sp)
	sw $s0, 20($sp)
	sw $s1, 16($sp)
	sw $s2, 12($sp)
	sw $s3, 8($sp)
	sw $s4, 4($sp)
	sw $s5, 0($sp)
	# ========================================================================================== #
	
	# ========================================================================================== #
	# carrega da memoria as informacoes das paredes
	la $s0, paredesX	
	la $s1, paredesY 
	la $s2, paredesExpandX
	la $s3, paredesExpandY
	la $s4, numParedes
	# ========================================================================================== #
	
	# ========================================================================================== #
	# Carregando os endereï¿½os dos valores das paredes da fase atual	
	move $a0,$s0
	jal carregaPosicaoAtualMatriz
	move $s0, $v0
	
	move $a0, $s1
	jal carregaPosicaoAtualMatriz
	move $s1, $v0
	
	move $a0, $s2
	jal carregaPosicaoAtualMatriz
	move $s2, $v0
	
	move $a0, $s3
	jal carregaPosicaoAtualMatriz
	move $s3, $v0
	
	move $a0, $s4			
	jal carregaPosicaoAtualVetor
	move $s4, $v0
	# ========================================================================================== #
	
	move $s5, $zero			# $s5 = 0
	lwc1 $f1, 0($s4)				
	cvt.w.s $f1, $f1
	mfc1 $s4, $f1			# $s4 = nro de paredes da fase
	
	# loop para plotar cada parede de cada vez
	vamosPlotarParedes:
	beq $s4, $s5, fimVamosPlotarParedes
	
	# ========================================================================================== #
	# Seta $t0 com a posicao inicial do bloco a ser plotado na tela
	lwc1 $f1, 0($s1)				
	cvt.w.s $f1, $f1
	mfc1 $t0, $f1				# $t0 = posicao Y da parede
	
	lwc1 $f1, 0($s0)				
	cvt.w.s $f1, $f1
	mfc1 $t1, $f1				# $t1 = posicao X da parede
	
	sll $t0, $t0, 12			# shifta o Y de 12
	add $t0, $t0, $t1			# adiciona X
	lui $t1, 0x8000				# $t1 = 0x80000000
	or $t0, $t0, $t1			# OR entre 0x80000000 e 0x000YYXXX
	# ========================================================================================== #
	lwc1 $f1, 0($s2)				
	cvt.w.s $f1, $f1
	mfc1 $t2, $f1				# converte de float para int o valor do expandX
	
	lwc1 $f1, 0($s3)				
	cvt.w.s $f1, $f1
	mfc1 $t3, $f1				# converte de float para int o valor do expandY
	# ========================================================================================== #
	move $a0, $t0				# $a0 = posiï¿½ï¿½o inicial XY do bloco
	move $a1, $t2				# $a1 = expandX 
	move $a2, $t3				# $a2 = expandY 
	li $a3, 0xB7				# $a3 = cor do bloco (bege)
	# ========================================================================================== #	
	jal loopImprimeBlocos
	addi $s5, $s5, 1	
	addi $s0, $s0, 4
	addi $s1, $s1, 4
	addi $s2, $s2, 4
	addi $s3, $s3, 4
	j vamosPlotarParedes
		
	fimVamosPlotarParedes:	
	# ========================================================================================== #
	# desempilha os regs salvos!
	lw $ra, 24($sp)
	lw $s0, 20($sp)
	lw $s1, 16($sp)
	lw $s2, 12($sp)
	lw $s3, 8($sp)
	lw $s4, 4($sp)
	lw $s5, 0($sp)
	addi $sp, $sp, 28
	# ========================================================================================== #
	
	jr $ra
	
	
# ====== LOOP QUE IMPRIME OS BLOCOS ====== #
# ====== ARGS:	$a0 = posicao XY inicial do bloco
# ======	$a1 = expandX
# ======	$a2 = expandY
# ======	$a3 = cor do bloco
loopImprimeBlocos:	

	#$t0 = posicï¿½ao XY inicial
	move $t0, $a0
	move $t4, $zero
	sll $t3, $a2, 3				# $t3 = expandY*8
	
	# LOOP PARA IMPRESSAO DOS BLOCOS #	
	loopImprimeBlocos1:
		beq $t3, $t4, fimLoopImprimeBlocos1
		move $t2, $zero			# $t2 = 0
		move $t1, $t0			# $t1 = posicao XY inicial
		loopImprimeBlocos2:
			beq $t2, $a1, fimLoopImprimeBlocos2
			sw $a3, 0($t1)
			sw $a3, 1($t1)
			sw $a3, 2($t1)
			sw $a3, 3($t1)
			sw $a3, 4($t1)
			sw $a3, 5($t1)
			sw $a3, 6($t1)
			sw $a3, 7($t1)
			addi $t1, $t1, 8	#$t1+8
			addi $t2, $t2, 1	#contadorX+1
			j loopImprimeBlocos2	
			
		fimLoopImprimeBlocos2:
		addi $t0, $t0, 0x1000		# $t0+0x1000 (pula a linha)
		addi $t4, $t4, 1		# contadorY+1
		j loopImprimeBlocos1
				
	fimLoopImprimeBlocos1:
	jr $ra



# ====== ROTINA PARA IMPRIMIR O PORCO NA TELA ====== #
imprimePorco:
	
	# ========================================================================================== #
	# abre espaï¿½o na pilha e empilha os registradores salvos
	addi $sp, $sp, -24
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $s1, 12($sp)
	sw $s2, 8($sp)
	sw $s3, 4($sp)
	sw $s4, 0($sp)
	# ========================================================================================== #
	
	# ========================================================================================== #
	# carrega da memoria as informacoes dos porcos
	la $s0, pigXPos
	la $s1, pigYPos
	la $s2, numPigs	
	la $s3, pigExiste
	# ========================================================================================== #	
	
	# ========================================================================================== #	
	move $a0, $s0
	jal carregaPosicaoAtualMatriz
	move $s0, $v0
	
	move $a0, $s1
	jal carregaPosicaoAtualMatriz
	move $s1, $v0
	
	move $a0, $s2
	jal carregaPosicaoAtualVetor
	move $s2, $v0
	
	move $a0, $s3
	jal carregaPosicaoAtualMatriz
	move $s3, $v0	
	# ========================================================================================== #	
	
	move $s4, $zero					# $s4 = 0
	l.s $f1, 0($s2)
	cvt.w.s $f1, $f1
	mfc1 $s2, $f1					# $s2 = nro de porcos na fase
	# ===== loop para plotar todos os porcos na fase ====== #
	vamosPlotarPorcos:
	beq $s2, $s4, fimVamosPlotarPorcos		#verifica se ainda ha porcos a serem verificados
	
	#verifica se o porco existe
	lwc1 $f1, 0($s3)				# $f1 = pigExiste do porco atual
	lwc1 $f2, const1				# $f2 = constante 1
	c.eq.s $f1, $f2				# verifica se pigExiste = 1
	bc1f vamosPlotaroProximoPorco		# se falso, pula pro proximo porrrco
	
	# ========================================================================================== #
	# Seta $t0 com a posicao inicial do porco a ser plotado na tela
	lwc1 $f1, 0($s1)				
	cvt.w.s $f1, $f1
	mfc1 $t0, $f1				# $t0 = posicao Y do porco
	
	lwc1 $f1, 0($s0)				
	cvt.w.s $f1, $f1
	mfc1 $t1, $f1				# $t1 = posicao X do porco
	
	sll $t0, $t0, 12			# shifta o Y de 12
	add $t0, $t0, $t1			# adiciona X
	lui $t1, 0x8000				# $t1 = 0x80000000
	or $t0, $t0, $t1			# OR entre 0x80000000 e 0x000YYXXX
	# ========================================================================================== #
	move $a0, $t0				# $a0 = posiï¿½ï¿½o inicial XY do porco
	la $a1, plotGpig			# $a1 = endereco da imagem do porco
	# ========================================================================================== #	
	jal loopImprimePorcos
	addi $s4, $s4, 1			# soma 1 no contador se o porco existir
	vamosPlotaroProximoPorco:
	addi $s0, $s0, 4
	addi $s1, $s1, 4
	addi $s3, $s3, 4
	j vamosPlotarPorcos
		
	fimVamosPlotarPorcos:	
	# ========================================================================================== #
	# desempilha os regs salvos!
	lw $ra, 20($sp)
	lw $s0, 16($sp)
	lw $s1, 12($sp)
	lw $s2, 8($sp)
	lw $s3, 4($sp)
	lw $s4, 0($sp)
	addi $sp, $sp, 24
	# ========================================================================================== #
	
	jr $ra
	
# ====== LOOP QUE IMPRIME OS PORCOS ====== #
# ====== ARGS:	$a0 = posicao XY inicial do porco
# ======	$a1 = plotGPig imagem do porco
loopImprimePorcos:	

	move $t0, $a0						# $t0 = posiï¿½ï¿½oXY do porco
	move $t1, $a1						# $t1 = posicao na matrix de cores
	li $t3, 0						# $t3 = contador de linhas
	
	loopImprimePorco1:
		beq $t3, 8, fimLoopImprimePorco1		# fim da impressao do porco
		li $t4, 0					# $t4 = contador de colunas
	
		loopImprimePorco2:
			beq $t4, 8, fimLoopImprimePorco2	# fim da impressao da linha
		
			lw $t5, 0($t1)				# $t5 carrega o valor do endereï¿½o do bloco de cores
			sw $t5, 0($t0)				# Plotta a cor na tela
			addi $t1, $t1, 4			# Avanï¿½a uma posiï¿½ï¿½o na matriz de cores
			addi $t0, $t0, 1			# Avanï¿½a para o prï¿½ximo pixel
					
			addi $t4, $t4, 1			# ï¿½ndice incrementado
		
			j loopImprimePorco2
		fimLoopImprimePorco2:
		
		addi $t0, $t0, 0xFF8				# pula pra proxima linha
		addi $t3, $t3, 1				#ï¿½ndice incrementado
		j loopImprimePorco1
	fimLoopImprimePorco1:
	jr $ra

# ====== LOOP QUE IMPRIME O ESTILINGUE MAGICO DOURADO ====== #
loopImprimeEstilingue:	

	lw $t0, posicaoEtg					# $t0 = posiï¿½ï¿½oXY do estilingue
	la $t1, plotEtg						# $t1 = posicao na matrix de cores
					
	li $t3, 0						# $t3 = contador de linhas
	
	loopImprimeEtg1:
		beq $t3, 24, fimLoopImprimeEtg1			# fim da impressao do estilingue
		li $t4, 0					# $t4 = contador de colunas
	
		loopImprimeEtg2:
			beq $t4, 8, fimLoopImprimeEtg2		# fim da impressao da linha
		
			lw $t5, 0($t1)				# $t5 carrega o valor do endereï¿½o do bloco de cores
			sw $t5, 0($t0)				# Plotta a cor na tela
			addi $t1, $t1, 4			# Avanï¿½a uma posiï¿½ï¿½o na matriz de cores
			addi $t0, $t0, 1			# Avanï¿½a para o prï¿½ximo pixel
					
			addi $t4, $t4, 1			# ï¿½ndice incrementado
		
			j loopImprimeEtg2
		fimLoopImprimeEtg2:
		
		addi $t0, $t0, 0xFF8				# pula pra proxima linha
		addi $t3, $t3, 1				# ï¿½ndice incrementado
		j loopImprimeEtg1
	fimLoopImprimeEtg1:
	jr $ra	
	

# ====== ROTINA PARA IMPRIMIR O NOSSO HEROI (PASSARO) NA TELA ====== #	
# ====== ARGS:	$a0 = xPassaro
# ======	$a1 = yPassaro
# ======	$f8 = massa do passaro
imprimePassaro:
	
	# ========================================================================================== #
	# abre espaco na pilha e empilha os registradores salvos
	addi $sp, $sp, -16
	sw $ra, 12($sp)
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $s2, 0($sp)
	# ========================================================================================== #
	
	# ========================================================================================== #
	# Seta $t0 com a posicao inicial do passaro
	move $t0, $a1			# $t0 = posicao Y do passaro
	
	move $t1, $a0				# $t1 = posicao X do passaro
	
	sll $t0, $t0, 12			# shifta o Y de 12
	add $t0, $t0, $t1			# adiciona X
	lui $t1, 0x8000				# $t1 = 0x80000000
	or $t0, $t0, $t1			# OR entre 0x80000000 e 0x000YYXXX
	move $a0, $t0				# $a0 = posicao inicial do passaro na forma 0x800YYXXX
	# ========================================================================================== #
	
	# ========================================================================================== #
	#verifica se o passaro e vermelho
	l.s $f1, massaRBird
	c.eq.s $f8, $f1
	bc1t oPassaroeVermelho
	#verifica se o passaro e azul
	l.s $f1, massaBBird
	c.eq.s $f8, $f1
	bc1t oPassaroeAzul
	#verifica se o passaro e vermelho
	l.s $f1, massaYBird
	c.eq.s $f8, $f1
	bc1t oPassaroeAmarelo
	# ========================================================================================== #
	
	# SETA O PASSARO COMO VERMELHO
	oPassaroeVermelho:
		la $a1, plotRbird
		j vamosPlotarPassaro
	# SETA O PASSARO COMO AZUL
	oPassaroeAzul:
		la $a1, plotBbird
		j vamosPlotarPassaro
	# SETA O PASSARO COMO AMARELO
	oPassaroeAmarelo:
		la $a1, plotYbird
		j vamosPlotarPassaro
		
	# ===== vamos plotar o passaro! ====== #
	# $a0 = posicao inicial XY do passaro
	# $a1 = endereco da imagem do passaro
	vamosPlotarPassaro:
	jal loopImprimePassaro

	# ========================================================================================== #	
	# desempilha os regs salvos!
	lw $ra, 12($sp)
	lw $s0, 8($sp)
	lw $s1, 4($sp)
	lw $s2, 0($sp)
	addi $sp, $sp, 16
	# ========================================================================================== #
	jr $ra
	
# ====== LOOP QUE IMPRIME O PASSARO ====== #
# ====== ARGS:	$a0 = posicao XY do passaro
# ======	$a1 = matrix de cores do passaro escolhido
loopImprimePassaro:	

	move $t0, $a0						# $t0 = posiï¿½ï¿½oXY do passaro
	move $t1, $a1						# $t1 = posicao na matrix de cores
	li $t3, 0						# $t3 = contador de linhas
	
	loopImprimePassaro1:
		beq $t3, 10, fimLoopImprimePassaro1		# fim da impressao do passaro
		li $t4, 0					# $t4 = contador de colunas
	
		loopImprimePassaro2:
			beq $t4, 10, fimLoopImprimePassaro2	# fim da impressao da linha
		
			lw $t5, 0($t1)				# $t5 carrega o valor do endereï¿½o do bloco de cores
			sw $t5, 0($t0)				# Plotta a cor na tela
			addi $t1, $t1, 4			# Avanï¿½a uma posiï¿½ï¿½o na matriz de cores
			addi $t0, $t0, 1			# Avanï¿½a para o prï¿½ximo pixel
					
			addi $t4, $t4, 1			# ï¿½ndice incrementado
		
			j loopImprimePassaro2
		fimLoopImprimePassaro2:
		
		addi $t0, $t0, 0xFF6				# pula pra proxima linha
		addi $t3, $t3, 1				# ï¿½ndice incrementado
		j loopImprimePassaro1
	fimLoopImprimePassaro1:
	
	#move $s2, $a0			#copia a posicao do passaro para conservacao
	#sleep
	#li $a0, 50
	#li $v0, 32
	#syscall 		
	#move $a0, $s2			#restaura a posicao do passaro
	
	
	jr $ra
	
# ====== LOOP QUE IMPRIME A EXPLOSAO ====== #
# ====== ARGS:	$a0 = posicao XY da explosao
# ======	$a1 = plotBoom1
# ======	$a2 = plotBoom2
loopImprimeExplosao:	

	
	li $t3, 0							# $t3 = contador de repeticoes da explosao
	
	loopImprimeExplosao1:
		beq $t3, 20, fimLoopImprimeExplosao1
		li $t4, 0						# $t4 = contador de linhas = 0
		li $t2, 2						
		div $t3, $t2
		mfhi $t2						# $t2 = $t3 mod 2
		move $t0, $a0							# $t0 = posiï¿½ï¿½oXY da explosao
		beq $t2, $zero, boom2
		boom1:							#imprime o primeiro bmp de explosao
			move $t1, $a1
			j loopImprimeExplosao2
		boom2:							#imprime o segundo bmp de explosao
			move $t1, $a2
			j loopImprimeExplosao2
		loopImprimeExplosao2:
			beq $t4, 8, fimLoopImprimeExplosao2		# fim da impressao da explosao
			li $t5, 0					# $t5 = contador de colunas
	
			loopImprimeExplosao3:
				beq $t5, 8, fimLoopImprimeExplosao3	# fim da impressao da linha
			
				lw $t6, 0($t1)				# $t6 carrega o valor do endereï¿½o do bloco de cores
				sw $t6, 0($t0)				# Plotta a cor na tela
				addi $t1, $t1, 4			# Avanï¿½a uma posiï¿½ï¿½o na matriz de cores
				addi $t0, $t0, 1			# Avanï¿½a para o prï¿½ximo pixel
						
				addi $t5, $t5, 1			# ï¿½ndice incrementado
			
				j loopImprimeExplosao3
			fimLoopImprimeExplosao3:
			
			addi $t0, $t0, 0xFF8				# pula pra proxima linha
			addi $t4, $t4, 1				#ï¿½ndice incrementado
			j loopImprimeExplosao2
		fimLoopImprimeExplosao2:
		#Syscall sleep
		move $t6, $a0						#salva $a0 $a0= 0x8000YYXXX
		li $a0, 70						# tempo = 50ms
		li $v0, 32
		syscall
		move $a0, $t6						#restaura $a0= 0x8000YYXXX
		#termino do sleep
							
		addi $t3, $t3, 1
		j loopImprimeExplosao1
	fimLoopImprimeExplosao1:
	jr $ra	
	
# ====== ROTINA DE INPUT DE TECLADO PARA LANCAMENTO ====== #
# ====== ARGS:	$a0 = posicao X Passaro
# ====== 	$a1 = posicai Y Passaro
# ======	$f8 = massa do passaro
# ====== 	OBS:	EMPILHAR OS REGISTRADORES SALVOS ANTES DE CHAMAR ESSA ROTINA!
# ======	OBS:	ZERAR O VALOR DE $s0 E $s1 ANTES DE CHAMAR ESSA ROTINA!
# ======	OBS:	$t2 = 100
inputTecladoLancamento:
	
	# ========================================================================================== #	
	lw $t0,0x40000020			#Armazena posicao do buffer do teclado em $t0
	li $t1,0X0000FF00			#Pega apenas o ultimo buffer
	and $t0, $t0, $t1
	# ========================================================================================== #	
	
	# ========================================================================================== #	
	beq $t0, 0x1D00, cimaBird		# SETA CIMA
	beq $t0, 0x2300, direitaBird		# SETA DIREITA
	beq $t0, 0x1B00, baixoBird		# SETA BAIXO
	beq $t0, 0x1C00, esquerdaBird		# SETA ESQUERDA
	beq $t0, 0x2900, fireBird		# ENTER para o alto e avante!		
	# ========================================================================================== #	
	
	j inputTecladoLancamento		# retorna para o loop de input
	
	
	
	# ========================================================================================== #
	# $s0 = puxada em X
	# $s1 = puxada em Y
	# $s2 = posicao X do passaro, armazenada para conservaï¿½ï¿½o
	# $t2 = 100
	# $t3 = flag
	# ========================================================================================== #	
	cimaBird:
		#caso Y == 0 nao executa o CimaBird
		slt $t3, $zero, $s1
		beq $t3, $zero, inputTecladoLancamento
		
		#Y -=10
		addi $s1, $s1, -5		
		subi $a0, $a0, 0x1000		# move o passaro para cima!
		jal loopImprimePassaro
	
		move $s2, $a0			#copia a posicao do passaro para conservacao
		#sleep
		li $a0, 50
		li $v0, 32
		syscall 		
		move $a0, $s2			#restaura a posicao do passaro
		
		li $t0,0x40000020			#Armazena posicao do buffer do teclado em $t0
		li $t1,0x00000000			#Pega apenas o ultimo buffer
		sw $t1, 0($t0)
		and $t0, $t0, $t1
	
 		j inputTecladoLancamento
	# ========================================================================================== #
	direitaBird:
		#caso X == 0 nao executa direitaBird
		slt $t3, $zero, $s0
		beq $t3, $zero, inputTecladoLancamento
		
		# X -=10
		addi $s0, $s0, -5		
		addi $a0, $a0, 0x0001		# move o passaro pra direita!
		jal loopImprimePassaro
		
		move $s2, $a0			#copia a posicao do passaro para conservacao
		#sleep
		li $a0, 50
		li $v0, 32
		syscall 		
		move $a0, $s2			#restaura a posicao do passaro		

		li $t0,0x40000020			#Armazena posicao do buffer do teclado em $t0
		li $t1,0x00000000			#Pega apenas o ultimo buffer
		sw $t1, 0($t0)
		and $t0, $t0, $t1
			
 		j inputTecladoLancamento
 	# ========================================================================================== #
	baixoBird:
		#caso Y == 100 nao executa baixoBird
		slt $t3, $s1, $t2
		beq $t3, $zero, inputTecladoLancamento
		
		# Y +=10
		addi $s1, $s1, 5		
		addi $a0, $a0, 0x1000		# move o passaro pra baixo!
		jal loopImprimePassaro
		
		move $s2, $a0			#copia a posicao do passaro para conservacao
		#sleep
		li $a0, 50
		li $v0, 32
		syscall 		
		move $a0, $s2			#restaura a posicao do passaro
		
		li $t0,0x40000020			#Armazena posicao do buffer do teclado em $t0
		li $t1,0x00000000			#Pega apenas o ultimo buffer
		sw $t1, 0($t0)
		and $t0, $t0, $t1
		
 		j inputTecladoLancamento
	# ========================================================================================== #
	esquerdaBird:
		#caso X == 100, nï¿½o executa esquerdabird
		slt $t3, $s0, $t2
		beq $t3, $zero, inputTecladoLancamento
		
		#X+=1
		addi $s0, $s0, 5
		subi $a0, $a0, 0x0001		# move o passaro pra esquerda!
		jal loopImprimePassaro
		
		move $s2, $a0			#copia a posicao do passaro para conservacao
		#sleep
		li $a0, 50
		li $v0, 32
		syscall 		
		move $a0, $s2			#restaura a posicao do passaro

		li $t0,0x40000020			#Armazena posicao do buffer do teclado em $t0
		li $t1,0x00000000			#Pega apenas o ultimo buffer
		sw $t1, 0($t0)
		and $t0, $t0, $t1

	 	j inputTecladoLancamento
	# ========================================================================================== #
	fireBird:
		move $v0, $s0			#coloca a puxada em X no reg de retorno $v0
		move $v1, $s1			#coloca a puxada em Y no reg de retorno $v1
		j inputTecladoOK	# jump pra funcao muito doida depois do loop de input do teclado
	

# ========================================================================================== #
# FUNCAO PARA ESCOLHER ESTILINGUES ========================================================= #
# ========================================================================================== #

escolhaEtg:
	
		# ========================================================================================== #
		# abre espaï¿½o na pilha e empilha os registradores salvos
		addi $sp, $sp, -16
		sw $ra, 12($sp)
		sw $s0, 8($sp)
		sw $s1, 4($sp)
		sw $s2, 0($sp)
		# ========================================================================================== #
	
		#jal loopImprimeChooseDestiny
		jal loopImprimeEscolhaETGMadeira
		jal loopImprimeEscolhaETGPrata
		jal loopImprimeEscolhaETGOuro
		jal inputTecladoEtg			#Le o teclado e carrega a const elastica em $f29
		
		# ========================================================================================== #
		# desempilha os regs salvos!
		lw $ra, 12($sp)
		lw $s0, 8($sp)
		lw $s1, 4($sp)
		lw $s2, 0($sp)
		addi $sp, $sp, 16
		# ========================================================================================== #
		
		jr $ra
#FIM DA ROTINA PARA ESCOLHER ESTILINGUE



# ====== LOOP QUE IMPRIME A TELA DE ESTILINGUES MADEIRA ====== #
	loopImprimeEscolhaETGMadeira:	

		la $t0, 0x80068060					# $t0 = posiï¿½ï¿½oXY da tela de estilingue
		la $t1, plotEstilingueMadeira						# $t1 = posicao na matrix de cores
					
		li $t3, 0						# $t3 = contador de linhas
	
		loopImprimeEscolhaEtgMadeira1:
			beq $t3, 46, fimloopImprimeEscolhaEtgMadeira1		# fim da impressao da tela de estilingue
			li $t4, 0					# $t4 = contador de colunas
	
			loopImprimeEscolhaEtgMadeira2:
				beq $t4, 12, fimloopImprimeEscolhaEtgMadeira2	# fim da impressao da linha
		
				lw $t5, 0($t1)				# $t5 carrega o valor do endereï¿½o do bloco de cores
				sw $t5, 0($t0)				# Plotta a cor na tela
				addi $t1, $t1, 4			# Avanï¿½a uma posiï¿½ï¿½o na matriz de cores
				addi $t0, $t0, 1			# Avanï¿½a para o prï¿½ximo pixel
					
				addi $t4, $t4, 1			# indice incrementado
		
				j loopImprimeEscolhaEtgMadeira2
			fimloopImprimeEscolhaEtgMadeira2:
		
			addi $t0, $t0, 0xFF4				# pula pra proxima linha 0x1000 - tamanho da linha
			addi $t3, $t3, 1				# indice incrementado
			j loopImprimeEscolhaEtgMadeira1
		fimloopImprimeEscolhaEtgMadeira1:
		jr $ra	
# FIM DA ROTINA PARA IMPRIMIR O ESTILINGUE DE MADEIRA NA TELA
# ====== LOOP QUE IMPRIME A TELA DE ESTILINGUE DE PRATA ====== #
	loopImprimeEscolhaETGPrata:	

		la $t0, 0x80068098					# $t0 = posiï¿½ï¿½oXY da tela de estilingue
		la $t1, plotEstilinguePrata					# $t1 = posicao na matrix de cores
					
		li $t3, 0						# $t3 = contador de linhas
	
		loopImprimeEscolhaETGPrata1:
			beq $t3, 46, fimloopImprimeEscolhaETGPrata1		# fim da impressao da tela de estilingue
			li $t4, 0					# $t4 = contador de colunas
	
			loopImprimeEscolhaETGPrata2:
				beq $t4, 12, fimloopImprimeEscolhaETGPrata2	# fim da impressao da linha
		
				lw $t5, 0($t1)				# $t5 carrega o valor do endereï¿½o do bloco de cores
				sw $t5, 0($t0)				# Plotta a cor na tela
				addi $t1, $t1, 4			# Avanï¿½a uma posiï¿½ï¿½o na matriz de cores
				addi $t0, $t0, 1			# Avanï¿½a para o prï¿½ximo pixel
					
				addi $t4, $t4, 1			# indice incrementado
		
				j loopImprimeEscolhaETGPrata2
			fimloopImprimeEscolhaETGPrata2:
		
			addi $t0, $t0, 0xFF4				# pula pra proxima linha 0x1000 - tamanho da linha
			addi $t3, $t3, 1				# indice incrementado
			j loopImprimeEscolhaETGPrata1
		fimloopImprimeEscolhaETGPrata1:
		jr $ra	
# FIM DA ROTINA PARA IMPRIMIR OS ESTILINGUE DE PRATA NA TELA

# ====== LOOP QUE IMPRIME A TELA DE ESTILINGUE DE OURO ====== #
	loopImprimeEscolhaETGOuro:	

		la $t0, 0x800680D8					# $t0 = posiï¿½ï¿½oXY da tela de estilingue
		la $t1, plotEstilingueOuro				# $t1 = posicao na matrix de cores
					
		li $t3, 0						# $t3 = contador de linhas
	
		loopImprimeEscolhaETGOuro1:
			beq $t3, 46, fimloopImprimeEscolhaETGOuro1		# fim da impressao da tela de estilingue
			li $t4, 0					# $t4 = contador de colunas
	
			loopImprimeEscolhaETGOuro2:
				beq $t4, 12, fimloopImprimeEscolhaETGOuro2	# fim da impressao da linha
		
				lw $t5, 0($t1)				# $t5 carrega o valor do endereï¿½o do bloco de cores
				sw $t5, 0($t0)				# Plotta a cor na tela
				addi $t1, $t1, 4			# Avanï¿½a uma posiï¿½ï¿½o na matriz de cores
				addi $t0, $t0, 1			# Avanï¿½a para o prï¿½ximo pixel
					
				addi $t4, $t4, 1			# indice incrementado
		
				j loopImprimeEscolhaETGOuro2
			fimloopImprimeEscolhaETGOuro2:
		
			addi $t0, $t0, 0xFF4				# pula pra proxima linha 0x1000 - tamanho da linha
			addi $t3, $t3, 1				# indice incrementado
			j loopImprimeEscolhaETGOuro1
		fimloopImprimeEscolhaETGOuro1:
		jr $ra	
# FIM DA ROTINA PARA IMPRIMIR O ESTILINGUE MAGICO DOURADO NA TELA
	
	
	
#===============ROTINA PARA LER A ESCOLHA DO ESTILINGUE ==================================#
	# ========== Retorna em $f29 a constante elastica do eslingue escolhido =================#
	inputTecladoEtg:
	
	# ========================================================================================== #	
	lw $t0,0x40000020			#Armazena posicao do buffer do teclado em $t0
	li $t1,0x0000FF00			#Pega apenas o ultimo buffer
	and $t0, $t0, $t1
	# ========================================================================================== #	
	
	# ========================================================================================== #	
	beq $t0, 0x1600, estilingue1		# ESTILINGUE 1
	beq $t0, 0x1E00, estilingue2		# ESTILINGUE 2
	beq $t0, 0x2600, estilingue3		# ESTILINGUE 3
	# ========================================================================================== #	
	
	j inputTecladoEtg
	
	
	
	# ========================================================================================== #
	# $a0 = Tipo do estilingue
	# ========================================================================================== #	
		estilingue1:
			l.s $f29, k1			#$f29 = contante elastica do eslingue leve
				
			#sleep
			li $a0, 100
			li $v0, 32
			syscall 	
	
 			jr $ra
		 estilingue2:
			l.s $f29, k2			#$f29 = contante elastica do eslingue medio
				
			#sleep
			li $a0, 100
			li $v0, 32
			syscall 	
	
 			jr $ra

	 	estilingue3:
			l.s $f29, k3			#$f29 = contante elastica do eslingue pesado
				
			#sleep
			li $a0, 100
			li $v0, 32
			syscall 	
	
	 		jr $ra
#==================FIM DA ROTINA INPUT TELCADO=============================#

# ================ ROTINA PARA IMPRIMIR A TELA DE YOUWIN ================= #
# ====== ARGS:	$a0 = posicao XY do youwin
# ======	$a1 = matrix de cores do youwin escolhido
imprimeWin:

	move $t0, $a0						# $t0 = posiï¿½ï¿½oXY na tela
	move $t1, $a1						# $t1 = posicao na matrix de cores
	li $t3, 0						# $t3 = contador de linhas
	
	loopImprimeWin1:
		beq $t3, 14, fimLoopImprimeWin1		# fim da impressao do porco
		li $t4, 0					# $t4 = contador de colunas
	
		loopImprimeWin2:
			beq $t4, 45, fimLoopImprimeWin2	# fim da impressao da linha
		
			lw $t5, 0($t1)				# $t5 carrega o valor do endereï¿½o do bloco de cores
			sw $t5, 0($t0)				# Plotta a cor na tela
			addi $t1, $t1, 4			# Avanï¿½a uma posiï¿½ï¿½o na matriz de cores
			addi $t0, $t0, 1			# Avanï¿½a para o prï¿½ximo pixel
					
			addi $t4, $t4, 1			# ï¿½ndice incrementado
		
			j loopImprimeWin2
		fimLoopImprimeWin2:
		
		addi $t0, $t0, 0xFD3				# pula pra proxima linha
		addi $t3, $t3, 1				#ï¿½ndice incrementado
		j loopImprimeWin1
	fimLoopImprimeWin1:
	jr $ra

# ================================================================== #
# ROTINA PARA IMPRIMIR NO $A0 NO LCD
# ================================================================== #
ImprimeLCD:la $t0,MSG1		#Texto no .data
	lui $t9, 0x7000   		# Endereco do LCD
	sw $zero,0x20($t9)  		# clear

	move $t1,$zero 			#inicializa contador do for
	li $t2,5

	LCDLOOP: beq $t1,$t2, LCDPONTO	#Loop Imprime a primeira linha do LCD
	lw $t4,0($t0)			#Carrega o texto em $t4
	
	sw $t4,0($t9)			#
	addi $t9,$t9,1			# Bloco que imprime no espaço t9 da LCD e anda 1 Byte no texto
	srl $t4,$t4,8			#
	
	sw $t4,0($t9)
	addi $t9,$t9,1
	srl $t4,$t4,8
	
	sw $t4,0($t9)
	addi $t9,$t9,1
	srl $t4,$t4,8
	
	sw $t4,0($t9)
	addi $t9,$t9,1
	addi $t0,$t0,4
	addi $t1,$t1,1
	j LCDLOOP
	
	LCDPONTO:lw $t4,-4($t0)		#
	sw $t4,0($t9)			# Centraliza a Pontuação
	addi $t9,$t9,1			#
	
	move $t5,$a0			# Recebe a pontuação do argumento e define que será representado por 6 dígitos
	addi $t6,$zero,100000		#
	
	slt $t7,$t5,$zero
	bne $t7,1,LCDLoop2
	abs $t5,$t5
	addi $t9,$t9,-1
	addi $t4,$zero,0x2D
	sw $t4,0($t9)
	addi $t9,$t9,1
	addi $t4, $zero, 0x20

	
	LCDLoop2:beq $t6,0,LCDFINALTELA	# Loop que imprime a pontuação
	div $t5,$t6			
	mfhi $t5
	mflo $t7
	addi $t8,$t7,0x30
	sw $t8,0($t9)
	addi $t9,$t9,1
	div $t6,$t6,10
	j LCDLoop2

	LCDFINALTELA:move $t1,$zero
	li $t2,5

	LCDLoop3:beq $t1,$t2,LCDFIM	# Loop que preenche o resto da LCD com espaços
	sw $t4,0($t9)
	addi $t9,$t9,1
	addi $t1,$t1,1
	j LCDLoop3

	LCDFIM:jr $ra
# ================================================ #
	

# ====== ROTINA QUE INDICA O FIM DE UM LOOP ====== #
fimLoop:	
	jr $ra

