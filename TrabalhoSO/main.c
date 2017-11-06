/*
 * Universidade de Brasília
 * Departamento de Ciência da Computação - IE
 * Sistemas Operacionais - Turma A - 2/2013
 * Professora: Alba Cristina M. A. de Melo
 *
 * Alunos:
 *  - Felipe Carvalho Gules - 08/29137
 *  - Lécio Pery Júnior - 10/0015182
 *
 * Trabalho de SO - Multi-Servidor de Impressão
 *=============================================
 *
 * Projeto de um serviço de impressão de mensagens de clientes previamente cadastrados.
 *
 * Arquitetura
 *============
 *
 * Sistema Operacional: Arch Linux
 * Kernel: Linux 3.11.6-1 x86_64
 * Compilador: GCC 4.8.2
 *
 * Instruções
 *===========
 *
 *  + Para compilar:
 *      $ make main
 *
 *  + Para executar:
 *      $ ./main
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/msg.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/wait.h>
#include <pthread.h>
#include <pthread.h>

#define CHILD_AMMOUNT 9
#define QUEUE_AMMOUNT 22
#define MESSAGE_SIZE 25
#define BASE_KEY 100015182 /* Minha matricula. */
#define MAX_MESSAGES 3 * CHILD_AMMOUNT
#define ACKED "1"
#define NACKED "0"
#define DELAY 0

//#define DEBUG_MODE_1

/*
 * Mapa das filas segundo suas keys (Key y = BASE_KEY + y):
 *	Key 0:
 * 		Spooler le, processo 0 escreve.
 *	Key 1:
 * 		Processo 0 le, processo 1 escreve.
 * 	Key 2:
 * 		Processo 0 le, processo 3 escreve.
 */

typedef struct
{

    long mtype; /* 2: mensagem, 1: entrando no spoopler, 3: saindo do spooler. */
    char mtext[MESSAGE_SIZE];

} Message;

typedef struct
{

    long mtype; /* De 0 ate 8 */
    char mtext[1];

} Ack;

int attach( int **pshm, int idShm );
char queueCreate( int *queueID );
char queueAttach( int *pointer, int index );
char queueDestroy( int queueID );
void setMessage( Message *message, long type, char text[] );
void setAck( Ack *acknowledgements, long destiny, char acked[] );
void *gerenteEntrada();
void *impressao();
void *gerenteSaida();


int *pshm;
Ack acknowledgements; /* Buffer de acks recebidos para avancar as steps de cada processo. */
Message receivedMessage;
int length;
int queueVector[QUEUE_AMMOUNT]; /* Todas as filas estao aqui. */
pthread_mutex_t um, dois, tres;

int main()
{

    int identity;
    int servidorImpressao;
    int idShm;
    int counter;


    int i, j;
    int ret;
    int step;
    int childAmmmount1;
    char success; /* Mensagem enviada com sucesso? */
    char sent; /* Informacao interna que diz que o processo se encontra no spooler. */
    Message personalMessage;


    pthread_t thread_ge, thread_gs, thread_imp;

    length = MAX_MESSAGES;
    i = 0;
    step = 0;
    sent = 'n'; /* Enviei a mensagem dessa rodada? */
    success = 'n'; /* Obtido somente quando o processo consegue sair do spoopler. */

    /* cria memoria*/
    if ((idShm = shmget(0x7324, sizeof(int), IPC_CREAT|0x1ff)) < 0)
    {
        printf("erro na criacao da fila\n");
        exit(1);
    }

    /* Cria as filas.
     * Ao fim, queueVector possui o ID das filas.
     */
    while( i <= QUEUE_AMMOUNT )
    {

        queueVector[i] = BASE_KEY + i;
#ifdef DEBUG_MODE_1
        printf("Key[%d]: %d\t", i, queueVector[i]);
#endif
        if( queueCreate( &queueVector[i] ) == 'n' )
        {

            printf( "Erro na criacao da fila %d(%d).\n", i, BASE_KEY + i );
            exit( 1 ); /* Se der erro na criacao das filas, ja sai do programa */

        }
#ifdef DEBUG_MODE_1
        printf("Queue[%d]: %d\n", i, queueVector[i]);
#endif
        i++;

    }

    for( identity = 0; identity < CHILD_AMMOUNT; identity++ )
    {

        servidorImpressao = fork();
        if( servidorImpressao == 0 ) break;

    }

    /*
 * --== Servidor de impressão ==--
 *
 * Composto de três funções(ou threads para a modalidade 'b'):
 *
 *  -- gerente_entrada:
 *      - Recebe a solicitação de entrada no pool;
 *      - Adiciona o cliente caso o pool não atinja 5, informando
 *        uma mensagem de sucesso ou falha.
 *
 *  -- impressão:
 *      - Recebe dados a serem impressos;
 *      - Verifica se o cliente está devidamente cadastrado;
 *      - Imprime os dados.
 *
 *  -- gerente_saida:
 *      - Retira o cliente do cadastro de clientes ativos.
 *
 */

    if( servidorImpressao )
    {

        attach( &pshm, idShm );
        *(pshm) = 9;
        length = 0;
        if( queueAttach( &queueVector[0], 0 ) == 'n' ) exit( 1 );
        if( queueAttach( &queueVector[13], 13 ) == 'n' ) exit( 1 );


        pthread_mutex_init(&um, NULL);
        pthread_mutex_init(&dois, NULL);
        pthread_mutex_init(&tres, NULL);

        ret = pthread_create(&thread_ge, NULL, &gerenteEntrada, NULL);
        if (ret)
        {
            printf("Error %d on thread GE \n", ret);
            perror("pthread_create");
            exit(-1);
        }

        ret = pthread_create(&thread_imp, NULL, &impressao, NULL);
        if (ret)
        {
            printf("Error %d on thread IMP \n", ret);
            perror("pthread_create");
            exit(-1);
        }
        ret = pthread_create(&thread_gs, NULL, &gerenteSaida, NULL);
        if (ret)
        {
            printf("Error %d on thread GS \n", ret);
            perror("pthread_create");
            exit(-1);
        }

        ret = pthread_join(thread_ge, NULL);
        if (ret)
        {
            printf("error waiting thread GE\n");
            perror("pthread_join");
            exit(-1);
        }

        ret = pthread_join(thread_imp, NULL);
        if (ret)
        {
            printf("error waiting thread IMP \n");
            perror("pthread_join");
            exit(-1);
        }
        ret = pthread_join(thread_gs, NULL);
        if (ret)
        {
            printf("error waiting thread GS\n");
            perror("pthread_join");
            exit(-1);
        }


        printf( "Servidor de Impressao terminado.\n\t >> Programa terminado\n" );
        /* Ainda nao ha garantia de que todas as filas estao vazias,
         * ao inves disso, ha garantia de que os processos morreram.
         */
        for( counter = 0; counter < CHILD_AMMOUNT; counter++ )
        {

            wait( &childAmmmount1 );
#ifdef DEBUG_MODE_1
            printf( "Filhos esperados: %d\n", counter + 1 );
#endif

        }

        /* Agora destruimos as filas de mensagens. */
        for( counter = 0; counter <= QUEUE_AMMOUNT; counter++ )
        {

            if( queueDestroy( queueVector[counter] ) == 'n' )
            {

                printf( "Erro ao destruir a fila de mensagens %d.\n", queueVector[counter] );

            }
            else
            {
#ifdef DEBUG_MODE_1
                printf( "Fila destruida: %d\n", queueVector[counter] );
#endif

            }

        }

        /* Deleta memoria compartilhada: */
        if (shmctl(idShm, IPC_RMID, sizeof(int) < 0))
            printf("Erro ao remover memoria compartilhada: %d.\n", errno);

        exit (0);

    }

    /*
 * --== Cliente ==--
 *
 * Processo responsável por criar e gerenciar os processos clientes
 * organizados segundo a estrutura lógica de malha (mesh)
 *
 */

    else
    {

        switch( identity )
        {

        case 0:
            attach( &pshm, idShm );
            if( queueAttach( &queueVector[0], 0 ) == 'n' ) exit( 1 ); /* Escreve */
            if( queueAttach( &queueVector[1], 1 ) == 'n' ) exit( 1 ); /* Le */
            if( queueAttach( &queueVector[3], 3 ) == 'n' ) exit( 1 ); /* Le */
            if( queueAttach( &queueVector[13], 13 ) == 'n' ) exit( 1 ); /* Le Ack */
            if( queueAttach( &queueVector[14], 14 ) == 'n' ) exit( 1 ); /* Escreve Ack */
            if( queueAttach( &queueVector[16], 16 ) == 'n' ) exit( 1 ); /* Escreve Ack */

            while(1)
            {

                //printf( "Filho: 0\n" );
                if ( success == 'n' ) /* Caso contrrario, o processo ja enviou a mensagem dele. */
                {

                    if( step == 0 )
                    {

                        /* Pede para entrar: */
                        if( sent == 'n' )
                        {

                            setMessage( &personalMessage, 11, "Don't care 0." );
                            if ( msgsnd( queueVector[0], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT ) >= 0 )
                            {

                                sent = 'y';

                            }

                        }

                    }
                    else if( step == 1 )
                    {

                        if( sent == 'n' ) /* Confirma se entrou no buffer: */
                        {

                            /* Envia a mensagem que de fato sera exibida: */
                            setMessage( &personalMessage, 12, "Message 0." );
                            msgsnd( queueVector[0], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT );
                            sent = 'y';

                        }

                    }
                    else if( step == 2 )
                    {

                        if( sent == 'n' )
                        {

                            /* Pede para sair: */
                            setMessage( &personalMessage, 13, "Don't care 0." );
                            msgsnd( queueVector[0], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT );
                            sent = 'y';

                        }

                    }

                }

                /* Recebendo um ACK aqui: */
                i = msgrcv( queueVector[13], &acknowledgements, 2, 0, IPC_NOWAIT );

                if ( i > 0 )
                {

                    /* Conversao que evita EINVAL: */
                    acknowledgements.mtype--;

                    /* Decisao: */
                    if( acknowledgements.mtype == 0 )
                    {

                        /* Entao e para o proprio processo */
                        if( !strcmp( acknowledgements.mtext, ACKED ) )
                        {

                            step++; /* Cada ACK avanca uma step. */
                            if( step == 3 ) success = 'y'; /* Mandei todas as minhas mensagens com sucesso. */

                        }
                        sent = 'n'; /* Forca o envio da proxima mensagem. */

                    }
                    else if( ( acknowledgements.mtype == 3 ) || ( acknowledgements.mtype == 6 ) )
                    {

                        /* Entao e para a fila de saida numero 14: */
                        acknowledgements.mtype++; /* Regenerando a mensagem para repassar */
                        msgsnd( queueVector[14], &acknowledgements, 2, IPC_NOWAIT );

                    }
                    else
                    {

                        /* Entao e para a fila de saida numero 15: */
                        acknowledgements.mtype++; /* Regenerando a mensagem para repassar */
                        msgsnd( queueVector[16], &acknowledgements, 2, IPC_NOWAIT );

                    }

                }

                /* Repassa mensagens aqui: */
                i = msgrcv( queueVector[3], &receivedMessage, MESSAGE_SIZE, 0, IPC_NOWAIT );
                if( i > 0 ) i = msgsnd( queueVector[0], &receivedMessage, MESSAGE_SIZE, IPC_NOWAIT );
                i = msgrcv( queueVector[1], &receivedMessage, MESSAGE_SIZE, 0, IPC_NOWAIT );
                if( i > 0 ) i = msgsnd( queueVector[0], &receivedMessage, MESSAGE_SIZE, IPC_NOWAIT );

                sleep( DELAY );

                if((success == 'y') && (*(pshm) <= 1))
                {
                    /* Morte do filho. */
                    printf( "Cliente %d terminado\n", identity );
                    *(pshm) = *(pshm) - 1;
                    break;
                }
            }
            break;

        case 1:
            attach( &pshm, idShm );
            if( queueAttach( &queueVector[1], 1 ) == 'n' ) exit( 1 ); /* Escreve */
            if( queueAttach( &queueVector[2], 2 ) == 'n' ) exit( 1 ); /* Le */
            if( queueAttach( &queueVector[4], 4 ) == 'n' ) exit( 1 ); /* Le */
            if( queueAttach( &queueVector[16], 16 ) == 'n' ) exit( 1 ); /* Le Ack */
            if( queueAttach( &queueVector[17], 17 ) == 'n' ) exit( 1 ); /* Escreve Ack */
            if( queueAttach( &queueVector[19], 19 ) == 'n' ) exit( 1 ); /* Escreve Ack */

            while(1)
            {

                //printf( "Filho: 1\n" );
                if ( success == 'n' ) /* Caso contrrario, o processo ja enviou a mensagem dele. */
                {

                    if( step == 0 )
                    {

                        /* Pede para entrar: */
                        if( sent == 'n' )
                        {

                            setMessage( &personalMessage, 21, "Don't care 1." );
                            if ( msgsnd( queueVector[1], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT ) >= 0 )
                            {

                                sent = 'y';

                            }

                        }

                    }
                    else if( step == 1 )
                    {

                        if( sent == 'n' ) /* Confirma se entrou no buffer: */
                        {

                            /* Envia a mensagem que de fato sera exibida: */
                            setMessage( &personalMessage, 22, "Message 1." );
                            msgsnd( queueVector[1], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT );
                            sent = 'y';

                        }

                    }
                    else if( step == 2 )
                    {

                        if( sent == 'n' )
                        {

                            /* Pede para sair: */
                            setMessage( &personalMessage, 23, "Don't care 1." );
                            msgsnd( queueVector[1], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT );
                            sent = 'y';

                        }

                    }

                }

                /* Recebendo um ACK aqui: */
                i = msgrcv( queueVector[16], &acknowledgements, 2, 0, IPC_NOWAIT );

                if ( i > 0 )
                {

                    /* Conversao que evita EINVAL: */
                    acknowledgements.mtype--;

                    /* Decisao: */
                    if( acknowledgements.mtype == 1 )
                    {

                        /* Entao e para o proprio processo */
                        if( !strcmp( acknowledgements.mtext, ACKED ) )
                        {

                            step++; /* Cada ACK avanca uma step. */
                            if( step == 3 ) success = 'y'; /* Mandei todas as minhas mensagens com sucesso. */
                        }
                        sent = 'n'; /* Forca o envio da proxima mensagem. */

                    }
                    else if( ( acknowledgements.mtype == 4 ) || ( acknowledgements.mtype == 7 ) )
                    {

                        /* Entao e para a fila de saida numero 14: */
                        acknowledgements.mtype++; /* Regenerando a mensagem para repassar */
                        msgsnd( queueVector[17], &acknowledgements, 2, IPC_NOWAIT );

                    }
                    else
                    {

                        /* Entao e para a fila de saida numero 15: */
                        acknowledgements.mtype++; /* Regenerando a mensagem para repassar */
                        msgsnd( queueVector[19], &acknowledgements, 2, IPC_NOWAIT );

                    }

                }

                /* Repassa mensagens aqui: */
                i = msgrcv( queueVector[2], &receivedMessage, MESSAGE_SIZE, 0, IPC_NOWAIT );
                if( i > 0 ) i = msgsnd( queueVector[1], &receivedMessage, MESSAGE_SIZE, IPC_NOWAIT );
                i = msgrcv( queueVector[4], &receivedMessage, MESSAGE_SIZE, 0, IPC_NOWAIT );
                if( i > 0 ) i = msgsnd( queueVector[1], &receivedMessage, MESSAGE_SIZE, IPC_NOWAIT );

                sleep( DELAY );

                if( (success == 'y') && (*(pshm) <= 2) )
                {
                    /* Morte do filho. */
                    printf( "Cliente %d terminado\n", identity );
                    *(pshm) = *(pshm) - 1;
                    break;
                }

            }
            break;

        case 2:

            attach( &pshm, idShm );
            if( queueAttach( &queueVector[2], 2 ) == 'n' ) exit( 1 ); /* Escreve */
            if( queueAttach( &queueVector[5], 5 ) == 'n' ) exit( 1 ); /* Le */
            if( queueAttach( &queueVector[20], 20 ) == 'n' ) exit( 1 ); /* Escreve Ack */
            if( queueAttach( &queueVector[19], 19 ) == 'n' ) exit( 1 ); /* Le Ack */

            while(1)
            {

                //printf( "Filho: 2\n" );
                if ( success == 'n' ) /* Caso contrrario, o processo ja enviou a mensagem dele. */
                {

                    if( step == 0 )
                    {

                        /* Pede para entrar: */
                        if( sent == 'n' )
                        {

                            setMessage( &personalMessage, 31, "Don't care 2." );
                            if ( msgsnd( queueVector[2], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT ) >= 0 )
                            {

                                sent = 'y';

                            }

                        }

                    }
                    else if( step == 1 )
                    {

                        if( sent == 'n' ) /* Confirma se entrou no buffer: */
                        {

                            /* Envia a mensagem que de fato sera exibida: */
                            setMessage( &personalMessage, 32, "Message 2." );
                            msgsnd( queueVector[2], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT );
                            sent = 'y';

                        }

                    }
                    else if( step == 2 )
                    {

                        if( sent == 'n' )
                        {

                            /* Pede para sair: */
                            setMessage( &personalMessage, 33, "Don't care 2." );
                            msgsnd( queueVector[2], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT );
                            sent = 'y';

                        }

                    }

                }

                /* Recebendo um ACK aqui: */
                i = msgrcv( queueVector[19], &acknowledgements, 2, 0, IPC_NOWAIT );

                if ( i > 0 )
                {

                    /* Conversao que evita EINVAL: */
                    acknowledgements.mtype--;

                    /* Decisao: */
                    if( acknowledgements.mtype == 2 )
                    {

                        /* Entao e para o proprio processo */
                        if( !strcmp( acknowledgements.mtext, ACKED ) )
                        {

                            step++; /* Cada ACK avanca uma step. */
                            if( step == 3 ) success = 'y'; /* Mandei todas as minhas mensagens com sucesso. */

                        }
                        sent = 'n'; /* Forca o envio da proxima mensagem. */

                    }
                    else
                    {

                        /* So pode ser pro 5 ou pro 8: */
                        acknowledgements.mtype++; /* Regenerando a mensagem para repassar */
                        msgsnd( queueVector[20], &acknowledgements, 2, IPC_NOWAIT );

                    }

                }

                /* Repassa mensagens aqui: */
                i = msgrcv( queueVector[5], &receivedMessage, MESSAGE_SIZE, 0, IPC_NOWAIT );
                if( i > 0 ) i = msgsnd( queueVector[2], &receivedMessage, MESSAGE_SIZE, IPC_NOWAIT );

                sleep( DELAY );

                if( (success == 'y') && (*(pshm) <= 3) )
                {
                    /* Morte do filho. */
                    printf( "Cliente %d terminado\n", identity );
                    *(pshm) = *(pshm) - 1;
                    break;
                }
            }
            break;

        case 3:
            attach( &pshm, idShm );
            if( queueAttach( &queueVector[3], 3 ) == 'n' ) exit( 1 ); /* Escreve */
            if( queueAttach( &queueVector[6], 6 ) == 'n' ) exit( 1 ); /* Le */
            if( queueAttach( &queueVector[8], 8 ) == 'n' ) exit( 1 ); /* Le */
            if( queueAttach( &queueVector[15], 15 ) == 'n' ) exit( 1 ); /* Escreve Ack */
            if( queueAttach( &queueVector[14], 14 ) == 'n' ) exit( 1 ); /* Le Ack */

            while(1)
            {

                //printf( "Filho: 3\n" );
                if ( success == 'n' ) /* Caso contrrario, o processo ja enviou a mensagem dele. */
                {

                    if( step == 0 )
                    {

                        /* Pede para entrar: */
                        if( sent == 'n' )
                        {

                            setMessage( &personalMessage, 41, "Don't care 3." );
                            if ( msgsnd( queueVector[3], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT ) >= 0 )
                            {

                                sent = 'y';

                            }

                        }

                    }
                    else if( step == 1 )
                    {

                        if( sent == 'n' ) /* Confirma se entrou no buffer: */
                        {

                            /* Envia a mensagem que de fato sera exibida: */
                            setMessage( &personalMessage, 42, "Message 3." );
                            msgsnd( queueVector[3], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT );
                            sent = 'y';

                        }

                    }
                    else if( step == 2 )
                    {

                        if( sent == 'n' )
                        {

                            /* Pede para sair: */
                            setMessage( &personalMessage, 43, "Don't care 3." );
                            msgsnd( queueVector[3], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT );
                            sent = 'y';

                        }

                    }

                }

                /* Recebendo um ACK aqui: */
                i = msgrcv( queueVector[14], &acknowledgements, 2, 0, IPC_NOWAIT );
                if ( i > 0 )
                {

                    /* Conversao que evita EINVAL: */
                    acknowledgements.mtype--;

                    /* Decisao: */
                    if( acknowledgements.mtype == 3 )
                    {

                        /* Entao e para o proprio processo */
                        if( !strcmp( acknowledgements.mtext, ACKED ) )
                        {

                            step++; /* Cada ACK avanca uma step. */
                            if( step == 3 ) success = 'y'; /* Mandei todas as minhas mensagens com sucesso. */

                        }
                        sent = 'n'; /* Forca o envio da proxima mensagem. */

                    }
                    else
                    {

                        /* So pode ser pro 6: */
                        acknowledgements.mtype++; /* Regenerando a mensagem para repassar */
                        msgsnd( queueVector[15], &acknowledgements, 2, IPC_NOWAIT );

                    }

                }

                /* Repassa mensagens aqui: */
                i = msgrcv( queueVector[8], &receivedMessage, MESSAGE_SIZE, 0, IPC_NOWAIT );
                if( i > 0 ) i = msgsnd( queueVector[3], &receivedMessage, MESSAGE_SIZE, IPC_NOWAIT );
                i = msgrcv( queueVector[6], &receivedMessage, MESSAGE_SIZE, 0, IPC_NOWAIT );
                if( i > 0 ) i = msgsnd( queueVector[3], &receivedMessage, MESSAGE_SIZE, IPC_NOWAIT );


                sleep( DELAY );

                if( (success == 'y') && (*(pshm) <= 5) )
                {
                    /* Morte do filho. */
                    printf( "Cliente %d terminado\n", identity );
                    *(pshm) = *(pshm) - 1;
                    break;
                }

            }
            break;

        case 4:
            attach( &pshm, idShm );
            if( queueAttach( &queueVector[4], 4 ) == 'n' ) exit( 1 ); /* Escreve */
            if( queueAttach( &queueVector[6], 6 ) == 'n' ) exit( 1 ); /* Escreve */
            if( queueAttach( &queueVector[7], 7 ) == 'n' ) exit( 1 ); /* Le */
            if( queueAttach( &queueVector[9], 9 ) == 'n' ) exit( 1 ); /* Le */
            if( queueAttach( &queueVector[18], 18 ) == 'n' ) exit( 1 ); /* Escreve Ack */
            if( queueAttach( &queueVector[17], 17 ) == 'n' ) exit( 1 ); /* Le Ack */

            while(1)
            {

                //printf( "Filho: 4\n" );
                if ( success == 'n' ) /* Caso contrrario, o processo ja enviou a mensagem dele. */
                {

                    if( step == 0 )
                    {

                        /* Pede para entrar: */
                        if( sent == 'n' )
                        {

                            setMessage( &personalMessage, 51, "Don't care 4." );
                            if( rand()%2 ){ i = 4; } else i = 6;
                            if ( msgsnd( queueVector[i], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT ) >= 0 )
                            {

                                sent = 'y';

                            }

                        }

                    }
                    else if( step == 1 )
                    {

                        if( sent == 'n' ) /* Confirma se entrou no buffer: */
                        {

                            /* Envia a mensagem que de fato sera exibida: */
                            setMessage( &personalMessage, 52, "Message 4." );
                            if( rand()%2 ){ i = 4; } else i = 6;
                            msgsnd( queueVector[i], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT );
                            sent = 'y';

                        }

                    }
                    else if( step == 2 )
                    {

                        if( sent == 'n' )
                        {

                            /* Pede para sair: */
                            setMessage( &personalMessage, 53, "Don't care 4." );
                            if( rand()%2 ){ i = 4; } else i = 6;
                            msgsnd( queueVector[i], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT );
                            sent = 'y';

                        }

                    }

                }

                /* Recebendo um ACK aqui: */
                i = msgrcv( queueVector[17], &acknowledgements, 2, 0, IPC_NOWAIT );
                if ( i > 0 )
                {

                    /* Conversao que evita EINVAL: */
                    acknowledgements.mtype--;

                    /* Decisao: */
                    if( acknowledgements.mtype == 4 )
                    {

                        /* Entao e para o proprio processo */
                        if( !strcmp( acknowledgements.mtext, ACKED ) )
                        {

                            step++; /* Cada ACK avanca uma step. */
                            if( step == 3 ) success = 'y'; /* Mandei todas as minhas mensagens com sucesso. */

                        }
                        sent = 'n'; /* Forca o envio da proxima mensagem. */

                    }
                    else
                    {

                        /* So pode ser pro 7: */
                        acknowledgements.mtype++; /* Regenerando a mensagem para repassar */
                        msgsnd( queueVector[18], &acknowledgements, 2, IPC_NOWAIT );

                    }

                }

                /* Repassa mensagens aqui: */
                i = msgrcv( queueVector[7], &receivedMessage, MESSAGE_SIZE, 0, IPC_NOWAIT );
                if( rand()%2 ){ j = 4; } else j = 6;
                if( i > 0 ) i = msgsnd( queueVector[j], &receivedMessage, MESSAGE_SIZE, IPC_NOWAIT );
                i = msgrcv( queueVector[9], &receivedMessage, MESSAGE_SIZE, 0, IPC_NOWAIT );
                if( rand()%2 ){ j = 4; } else j = 6;
                if( i > 0 ) i = msgsnd( queueVector[j], &receivedMessage, MESSAGE_SIZE, IPC_NOWAIT );

                sleep( DELAY );

                if( (success == 'y') && (*(pshm) <= 4) )
                {
                    /* Morte do filho. */
                    printf( "Cliente %d terminado\n", identity );
                    *(pshm) = *(pshm) - 1;
                    break;
                }


            }
            break;

        case 5:
            attach( &pshm, idShm );
            if( queueAttach( &queueVector[5], 5 ) == 'n' ) exit( 1 ); /* Escreve */
            if( queueAttach( &queueVector[7], 7 ) == 'n' ) exit( 1 ); /* Escreve */
            if( queueAttach( &queueVector[10], 10 ) == 'n' ) exit( 1 ); /* Le */
            if( queueAttach( &queueVector[21], 21 ) == 'n' ) exit( 1 ); /* Escreve Ack */
            if( queueAttach( &queueVector[20], 20 ) == 'n' ) exit( 1 ); /* Le Ack */

            while(1)
            {

                //printf( "Filho: 5\n" );
                if ( success == 'n' ) /* Caso contrrario, o processo ja enviou a mensagem dele. */
                {

                    if( step == 0 )
                    {

                        /* Pede para entrar: */
                        if( sent == 'n' )
                        {

                            setMessage( &personalMessage, 61, "Don't care 5." );
                            if( rand()%2 ){ i = 5; } else i = 7;
                            if ( msgsnd( queueVector[i], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT ) >= 0 )
                            {

                                sent = 'y';

                            }

                        }

                    }
                    else if( step == 1 )
                    {

                        if( sent == 'n' ) /* Confirma se entrou no buffer: */
                        {

                            /* Envia a mensagem que de fato sera exibida: */
                            setMessage( &personalMessage, 62, "Message 5." );
                            if( rand()%2 ){ i = 5; } else i = 7;
                            msgsnd( queueVector[i], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT );
                            sent = 'y';

                        }

                    }
                    else if( step == 2 )
                    {

                        if( sent == 'n' )
                        {

                            /* Pede para sair: */
                            setMessage( &personalMessage, 63, "Don't care 5." );
                            if( rand()%2 ){ i = 5; } else i = 7;
                            msgsnd( queueVector[i], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT );
                            sent = 'y';

                        }

                    }

                }

                /* Recebendo um ACK aqui: */
                i = msgrcv( queueVector[20], &acknowledgements, 2, 0, IPC_NOWAIT );

                if ( i > 0 )
                {

                    /* Conversao que evita EINVAL: */
                    acknowledgements.mtype--;

                    /* Decisao: */
                    if( acknowledgements.mtype == 5 )
                    {

                        /* Entao e para o proprio processo */
                        if( !strcmp( acknowledgements.mtext, ACKED ) )
                        {

                            step++; /* Cada ACK avanca uma step. */
                            if( step == 3 ) success = 'y'; /* Mandei todas as minhas mensagens com sucesso. */

                        }
                        sent = 'n'; /* Forca o envio da proxima mensagem. */

                    }
                    else
                    {

                        /* So pode ser pro 8: */
                        acknowledgements.mtype++; /* Regenerando a mensagem para repassar */
                        msgsnd( queueVector[21], &acknowledgements, 2, IPC_NOWAIT );

                    }

                }

                /* Repassa mensagens aqui: */
                i = msgrcv( queueVector[10], &receivedMessage, MESSAGE_SIZE, 0, IPC_NOWAIT );
                if( rand()%2 ){ j = 5; } else j = 7;
                if( i > 0 ) i = msgsnd( queueVector[j], &receivedMessage, MESSAGE_SIZE, IPC_NOWAIT );

                sleep( DELAY );

                if( (success == 'y') && (*(pshm) <= 6) )
                {
                    /* Morte do filho. */
                    printf( "Cliente %d terminado\n", identity );
                    *(pshm) = *(pshm) - 1;
                    break;
                }

            }
            break;

        case 6:
            attach( &pshm, idShm );
            if( queueAttach( &queueVector[8], 8 ) == 'n' ) exit( 1 ); /* Escreve */
            if( queueAttach( &queueVector[11], 11 ) == 'n' ) exit( 1 ); /* Escreve */
            if( queueAttach( &queueVector[15], 15 ) == 'n' ) exit( 1 ); /* Le Ack */

            while(1)
            {

                //printf( "Filho: 6\n" );
                if ( success == 'n' ) /* Caso contrrario, o processo ja enviou a mensagem dele. */
                {

                    if( step == 0 )
                    {

                        /* Pede para entrar: */
                        if( sent == 'n' )
                        {

                            setMessage( &personalMessage, 71, "Don't care 6." );
                            if( rand()%2 ){ i = 8; } else i = 11;
                            if ( msgsnd( queueVector[i], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT ) >= 0 ) /* >= 0 e o conjunto complementar de < 0 */
                            {

                                sent = 'y';

                            }

                        }

                    }
                    else if( step == 1 )
                    {

                        if( sent == 'n' ) /* Confirma se entrou no buffer: */
                        {

                            /* Envia a mensagem que de fato sera exibida: */
                            setMessage( &personalMessage, 72, "Message 6." );
                            if( rand()%2 ){ i = 8; } else i = 11;
                            msgsnd( queueVector[i], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT );
                            sent = 'y';

                        }

                    }
                    else if( step == 2 )
                    {

                        if( sent == 'n' )
                        {

                            /* Pede para sair: */
                            setMessage( &personalMessage, 73, "Don't care 6." );
                            if( rand()%2 ){ i = 8; } else i = 11;
                            msgsnd( queueVector[i], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT );
                            sent = 'y';

                        }

                    }

                }

                /* Recebendo um ACK aqui: */
                i = msgrcv( queueVector[15], &acknowledgements, 2, 0, IPC_NOWAIT );

                if ( i > 0 )
                {

                    /* Conversao que evita EINVAL: */
                    acknowledgements.mtype--;

                    /* Sempre e para o proprio processo */
                    if( !strcmp( acknowledgements.mtext, ACKED ) )
                    {

                        step++; /* Cada ACK avanca uma step. */
                        if( step == 3 ) success = 'y'; /* Mandei todas as minhas mensagens com sucesso. */

                    }

                    sent = 'n'; /* Forca o envio da proxima mensagem. */

                }

                if( (success == 'y') && (*(pshm) <= 9) )
                {
                    /* Morte do filho. */
                    printf( "Cliente %d terminado\n", identity );
                    *(pshm) = *(pshm) - 1;
                    break;
                }

                sleep( DELAY );

            }
            break;

        case 7:
            attach( &pshm, idShm );
            if( queueAttach( &queueVector[9], 9 ) == 'n' ) exit( 1 ); /* Escreve */
            if( queueAttach( &queueVector[11], 11 ) == 'n' ) exit( 1 ); /* Le */
            if( queueAttach( &queueVector[12], 12 ) == 'n' ) exit( 1 ); /* Le */
            if( queueAttach( &queueVector[18], 18 ) == 'n' ) exit( 1 ); /* Le Ack */

            while(1)
            {

                if ( success == 'n' ) /* Caso contrrario, o processo ja enviou a mensagem dele. */
                {
                    if( step == 0 )
                    {
                        /* Pede para entrar: */
                        if( sent == 'n' )
                        {

                            setMessage( &personalMessage, 81, "Don't care 7." );
                            if ( msgsnd( queueVector[9], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT ) >= 0 )
                            {

                                sent = 'y';

                            }

                        }

                    }
                    else if( step == 1 )
                    {
                        if( sent == 'n' ) /* Confirma se entrou no buffer: */
                        {

                            /* Envia a mensagem que de fato sera exibida: */
                            setMessage( &personalMessage, 82, "Message 7." );
                            msgsnd( queueVector[9], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT );
                            sent = 'y';

                        }

                    }
                    else if( step == 2 )
                    {

                        if( sent == 'n' )
                        {

                            /* Pede para sair: */
                            setMessage( &personalMessage, 83, "Don't care 7." );
                            msgsnd( queueVector[9], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT );
                            sent = 'y';

                        }

                    }

                }

                /* Recebendo um ACK aqui: */
                i = msgrcv( queueVector[18], &acknowledgements, 2, 0, IPC_NOWAIT );

                if ( i > 0 )
                {

                    /* Conversao que evita EINVAL: */
                    acknowledgements.mtype--;

                    /* Sempre e para o proprio processo */
                    if( !strcmp( acknowledgements.mtext, ACKED ) )
                    {

                        step++; /* Cada ACK avanca uma step. */
                        if( step == 3 ) success = 'y'; /* Mandei todas as minhas mensagens com sucesso. */

                    }

                    sent = 'n'; /* Forca o envio da proxima mensagem. */

                }

                /* Repassa mensagens aqui: */
                i = msgrcv( queueVector[11], &receivedMessage, MESSAGE_SIZE, 0, IPC_NOWAIT );
                if( i > 0 ) i = msgsnd( queueVector[9], &receivedMessage, MESSAGE_SIZE, IPC_NOWAIT );
                i = msgrcv( queueVector[12], &receivedMessage, MESSAGE_SIZE, 0, IPC_NOWAIT );
                if( i > 0 ) i = msgsnd( queueVector[9], &receivedMessage, MESSAGE_SIZE, IPC_NOWAIT );

                sleep( DELAY );

                if( (success == 'y') && (*(pshm) <= 7) )
                {
                    /* Morte do filho. */
                    printf( "Cliente %d terminado\n", identity );
                    *(pshm) = *(pshm) - 1;
                    break;
                }

            }
            break;

        case 8:
            attach( &pshm, idShm );
            if( queueAttach( &queueVector[10], 10 ) == 'n' ) exit( 1 ); /* Escreve */
            if( queueAttach( &queueVector[12], 12 ) == 'n' ) exit( 1 ); /* Escreve */
            if( queueAttach( &queueVector[21], 21 ) == 'n' ) exit( 1 ); /* Le Ack */

            while(1)
            {

                //printf( "Filho: 8\n" );
                if ( success == 'n' ) /* Caso contrrario, o processo ja enviou a mensagem dele. */
                {

                    if( step == 0 )
                    {

                        /* Pede para entrar: */
                        if( sent == 'n' )
                        {

                            setMessage( &personalMessage, 91, "Don't care 8." );
                            if( rand()%2 ){ i = 10; } else i = 12;
                            if ( msgsnd( queueVector[i], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT ) >= 0 ) /* >= 0 e o conjunto complementar de < 0 */
                            {

                                sent = 'y';

                            }

                        }

                    }
                    else if( step == 1 )
                    {

                        if( sent == 'n' ) /* Confirma se entrou no buffer: */
                        {

                            /* Envia a mensagem que de fato sera exibida: */
                            setMessage( &personalMessage, 92, "Message 8." );
                            if( rand()%2 ){ i = 10; } else i = 12;
                            msgsnd( queueVector[i], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT );
                            sent = 'y';

                        }

                    }
                    else if( step == 2 )
                    {

                        if( sent == 'n' )
                        {

                            /* Pede para sair: */
                            setMessage( &personalMessage, 93, "Don't care 8." );
                            if( rand()%2 ){ i = 10; } else i = 12;
                            msgsnd( queueVector[i], &personalMessage, MESSAGE_SIZE, IPC_NOWAIT );
                            sent = 'y';

                        }

                    }

                }

                /* Recebendo um ACK aqui: */
                i = msgrcv( queueVector[21], &acknowledgements, 2, 0, IPC_NOWAIT );

                if ( i > 0 )
                {

                    /* Conversao que evita EINVAL: */
                    acknowledgements.mtype--;

                    /* Sempre e para o proprio processo */

                    if( !strcmp( acknowledgements.mtext, ACKED ) )
                    {

                        step++; /* Cada ACK avanca uma step. */
                        if( step == 3 ) success = 'y'; /* Mandei todas as minhas mensagens com sucesso. */

                    }
                    sent = 'n'; /* Forca o envio da proxima mensagem. */

                }

                if( (success == 'y') && (*(pshm) <= 9) )
                {
                    /* Morte do filho. */
                    printf( "Cliente %d terminado\n", identity );
                    *(pshm) = *(pshm) - 1;
                    break;
                }

                sleep( DELAY );

            }
            break;

        }

        /* Signal aqui. */
        exit( 0 );

    }
    return ( 0 );

}

int attach( int **pshm, int idShm )
{

    *(pshm) = (int *) shmat(idShm, (char *)0, 0);
    if ( *(pshm) == (int *) -1 )
    {
        printf("erro no attach\n");
        exit(1);
    }

    return 0;
}

char queueCreate( int *queueID )
{

    *( queueID ) = msgget( *( queueID ), IPC_CREAT|0x1ff );
    if ( *( queueID ) < 0 ) return 'n';
    return 's'; /* Sucesso */

}

char queueAttach( int *pointer, int index )
{

    *( pointer ) = msgget( BASE_KEY + index, 0x1ff );
    if( *pointer < 0 ) return 'n';
    return 's';

}

char queueDestroy( int queueID )
{

    struct msqid_ds buf; /* Mera exigencia. */
    queueID = msgctl( queueID, IPC_RMID, &buf );
    if ( queueID < 0 ) return 'n';
    return 's'; /* Sucesso */

}

void setMessage( Message *message, long type, char text[] )
{

    message->mtype = type;
    strcpy( message->mtext, text );

}

void setAck( Ack *acknowledgements, long destiny, char acked[] )
{

    acknowledgements->mtype = destiny/10;
    strcpy( acknowledgements->mtext, acked );

}


/*
 *  -- gerente_entrada:
 *      - Recebe a solicitação de entrada no pool;
 *      - Adiciona o cliente caso o pool não atinja 5, informando
 *        uma mensagem de sucesso ou falha.
 */

void *gerenteEntrada()
{

    int i;

    while(1)
    {
        /* Aqui fica nosso spooler de impressao: */
        if( *(pshm) == 0 ) break;
        i = 1; /* Obriga a mensagem ser certa */
        while( (i != MESSAGE_SIZE) && ( *(pshm) ) )
        {

            i = msgrcv(queueVector[0], &receivedMessage, MESSAGE_SIZE, 0, IPC_NOWAIT );

        }

        if (( length == 5 ) && (receivedMessage.mtype%10 == 1 )) setAck( &acknowledgements, receivedMessage.mtype, NACKED );
        else
        {
            if (receivedMessage.mtype%10 == 1) printf("[GERENTE_E]\t>>\t Processo %ld entrou no Spooler\n", receivedMessage.mtype/10 - 1);
            /*Otimizar o if acima causa condição de corrida.
         *Portanto a verificação (receivedMessage.mtype%10 == 1 ) deve ser feita com duplicidade.
         *É uma solução elegante que evita o uso de semáforo, não criando uma condição de corrida.
        */
            setAck( &acknowledgements, receivedMessage.mtype, ACKED );
        }

        if ( (receivedMessage.mtype%10 == 1) && (length != 5)) length++;

        pthread_mutex_unlock(&um);
        pthread_mutex_unlock(&dois);
        pthread_mutex_lock(&tres);
        pthread_mutex_lock(&tres);
    }
    pthread_exit(NULL);

}

/*
 *  -- impressão:
 *      - Recebe dados a serem impressos;
 *      - Verifica se o cliente está devidamente cadastrado; (.mtype == 2)
 *      - Imprime os dados.
 */

void *impressao()
{
    while(1)
    {
        pthread_mutex_lock(&um);


        /* Aqui fica nosso spooler de impressao: */
        if( *(pshm) == 0 ) break;
        if (receivedMessage.mtype%10 == 2 )
            printf( "[IMPRESSAO]\t>>\t Mensagem recebida: %s \n", receivedMessage.mtext);

        pthread_mutex_unlock(&tres);
    }
    pthread_exit(NULL);
}

/*
*  -- gerente_saida:
*      - Retira o cliente do cadastro de clientes ativos.
*      - Envia a confirmação preparada pelo gerente de entrada.
*/

void *gerenteSaida()
{
    while(1)
    {
        pthread_mutex_lock(&dois);
        /* Aqui fica nosso spooler de impressao: */
        if( *(pshm) == 0 ) break;
        /*
     *A verificação do pshm apenas impede que a mensagem de saida seja imprimida duas vezes ao final da execução
     */
        if (( receivedMessage.mtype%10 == 3 ) && *(pshm ) )
        {
            length--;
            printf("[GERENTE_S]\t>>\t Processo %ld saiu no Spooler\n", receivedMessage.mtype/10 - 1) ;
        }

        msgsnd( queueVector[13], &acknowledgements, 2, IPC_NOWAIT );
        /*
     * Assumindo que o número máximo de Acks simultâneos em todas as filas do sistema é 9,
     *não há como congestionar a fila de resposta e o msgsnd sempre será bem sucedido.
     * Também não há probabilidade de ele enviar lixo porque isso já foi verificado no gerente de entrada, responsável pela chamada da função setAck.
     * O gerente de entrada apenas prepara a resposta, mas quem efetivamente envia é o gerente de saida.
     */
        pthread_mutex_unlock(&tres);
    }
    pthread_exit(NULL);
}
