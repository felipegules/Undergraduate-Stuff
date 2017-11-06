Projeto Angry FPGA Birds
Brasília, 10 de Outubro de 2012
Universidade de Brasília
Departamento de Ciência da Computação
Organização e Arquitetura de Computadores
Turma A - Marcus Vinicius Lamar



Grupo 2
André França - 10/0007457
Felipe Carvalho Gules - 08/29137
Filipe Tancredo Barros - 10/0029329
Guilherme Ferreira - 12/0051133
Vitor Coimbra de Oliveira - 10/0021832

1. Introdução

	Este projeto visa implementar uma versão simplificada do jogo Angry Birds em Assembly MIPS, tirando proveito das implementações dos Coprocessadores 1 nos processadores MIPS Uniciclo, Multiciclo e Pipeline realizadas durante o período letivo.
	
2. Objetivos

	Desenvolver um jogo semelhante ao Angry Birds usando conhecimentos obtidos durante a disciplina de OAC.
	O jogo possui:
3 Fases com dificuldade crescente;
Diferentes tipos de pássaros;
Diferentes tipos de estruturas de alvos;
Física realística que calcula a trajetória baseada na força empregada, ângulo de elevação, ação da gravidade e tipo de pássaro;
Física simples do alvo (Explosão);
Contagem de pontos;
Diferentes tipos de estilingue (forte, médio, fraco)

3. Metodologia

	Logo após a entrega do roteiro do projeto, o grupo se encarregou de desenvolver a parte do software (teórica) sem aplicação no hardware.
	Primeiramente, concordamos em como representar a física do lançamento do pássaro e como representaríamos os porcos e as paredes. Durante esse período, atingimos um nível satisfatório de desenvolvimento do software e paralelamente, a parte gráfica do jogo estava sendo desenvolvida e constantemente testada. À medida que aprendíamos a desenvolver uma FPU, implementávamos os caminhos de dados do Coprocessador 1 em cada processador MIPS.
	Após a conclusão da implementação dos Coprocessadores 1 nos processadores Uniciclo e Multiciclo, nos responsabilizamos de integrar as partes geradas (jogo, gráficos e teclado).

4. Resultados Obtidos

	Inicialmente obtivemos resultados teóricos satisfatórios quanto a física do jogo. Após a junção do das partes do jogo (física, gráfico e teclado),  tivemos que fazer muitas adaptações. Testamos nos processadores Uniciclo e Multiciclo com FPU, Tudo ocorreu como o esperado e obtivemos sucesso na implementação do jogo.
	Duas implementações de FPU, Uniciclo e Multiciclo, funcionaram muito bem, e rodaram testes extensivos, além de que os bugs e ‘Warning’ de compilação antigos que interferiam com o funcionamento da placa foram corrigidos com sucesso. Ao final regulamos a velocidade de clock para ajustar a velocidade do jogo além de ajustes de tempo no código assembly do jogo.
	Por necessidade, o hardware foi modificado para adaptar a memória de dados usada pelo MARS com a memória dos processadores, garantido que os endereços corretos sejam carregados.

5. Conclusões e Trabalhos futuros

	Ao final, todo nosso esforço foi recompensado com a conclusão desse projeto. Aprimoramos nossos conhecimento em programação Assembly MIPS e no desenvolvimento em Verilog.

6. Referência Bibliografica
	- MIPS reference manual, PATTERSON
	- Manual Quartus e Altera
	- Manual MIPS do Mars (tecla F1).

7.Link do video no YouTube
 http://youtu.be/ciXNMbZL5zU
