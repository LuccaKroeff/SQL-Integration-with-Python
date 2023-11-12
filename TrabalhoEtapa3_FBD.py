# Conexão com MySQL
import mysql.connector

# Bibliotecas utilizadas para construção das interfaces
import tkinter as tk
import tkinter.ttk as ttk

# Consultas com parâmetros são realizadas através da função RealizarConsultaParametro
def RealizarConsultaParametro(num, parametro):
    global tabela

    if(num == 1):
        botao_uber_black.destroy()
        botao_uber_flash.destroy()
        botao_uber_x.destroy()

        consulta = f'SELECT m.nro_celular_motorista, m.modelo_veiculo, COUNT(*) AS total_corridas\
                        FROM Motoristas m\
                        JOIN Viagens v ON v.nro_celular_motorista = m.nro_celular_motorista\
                        WHERE m.categoria_motorista = %s\
                        GROUP BY m.nro_celular_motorista\
                        ORDER BY total_corridas DESC\
                        LIMIT 10;'
            
        cursor.execute(consulta, [parametro])
        resultado = cursor.fetchall()

        tabela = ttk.Treeview(frame, columns=("nro_celular_motorista", "modelo_veiculo", "total_corridas"), show="headings")
        tabela.heading("nro_celular_motorista", text="Número de celular do motorista")
        tabela.heading("modelo_veiculo", text="Modelo veículo")
        tabela.heading("total_corridas", text="Total de corridas realizadas")
        tabela.grid(row=0, column=2, rowspan=12, padx=10, pady=5)

        for i in resultado:
            tabela.insert("", "end", values=i)
    
    elif(num == 2):
        botao_consultar.destroy()
        label_dias.destroy()
        caixa_texto.destroy()

        consulta = f"SELECT nome_cupom, COUNT(*) AS vezes_utilizado \
                FROM PossesCupons \
                JOIN Viagens ON PossesCupons.codigo_viagem = Viagens.codigo_viagem \
                WHERE data_viagem BETWEEN DATE_SUB(NOW(), INTERVAL %s DAY) AND NOW() \
                GROUP BY nome_cupom \
                HAVING vezes_utilizado >= 2 \
                ORDER BY vezes_utilizado DESC;"
    
        cursor.execute(consulta, [parametro])
        resultado = cursor.fetchall()

        tabela = ttk.Treeview(frame, columns=("nome_cupom", "vezes_utilizado"), show="headings")
        tabela.heading("nome_cupom", text="Nome do Cupom")
        tabela.heading("vezes_utilizado", text="Total de vezes utilizado")
        tabela.grid(row=0, column=2, rowspan=12, padx=10, pady=5)

        for i in resultado:
            tabela.insert("", "end", values=i)

        
    elif(num == 3):
        botao_consultar.destroy()
        label_avaliacao.destroy
        caixa_texto.destroy()

        consulta = f"SELECT DISTINCT nome, nro_celular_cliente \
                   FROM clientes_cartoes C JOIN pessoas ON C.nro_celular_cliente = pessoas.nro_celular \
                   WHERE NOT EXISTS ( SELECT * \
                                      FROM viagens V NATURAL JOIN motoristas \
                                      WHERE C.nro_celular_cliente = V.nro_celular_cliente AND motoristas.avaliacao < %s) \
                   AND NOT EXISTS(SELECT * \
                                  FROM reclamacoes R \
                                  WHERE R.nro_celular_cliente = C.nro_celular_cliente);.format(parametro)" 
        
        cursor.execute(consulta, [parametro])
        resultado = cursor.fetchall()

        tabela = ttk.Treeview(frame, columns=("nome", "nro_celular_cliente"), show="headings")
        tabela.heading("nome", text="Nome do cliente")
        tabela.heading("nro_celular_cliente", text="Número de celular")
        tabela.grid(row=0, column=2, rowspan=12, padx=10, pady=5)

        for i in resultado:
            tabela.insert("", "end", values=i)


# Consultas são realizadas através da função RealizarConsulta
def RealizarConsulta(num):
    global tabela
    global tabela_existe
    global botao_uber_black
    global botao_uber_flash
    global botao_uber_x
    global botao_consultar
    global label_dias
    global label_avaliacao
    global caixa_texto

    # Se a tabela existe, excluímos essa tabela para mostrarmos o resultado da nova consulta
    if(tabela_existe == False):
        tabela_existe = True
    else:
        tabela.destroy()

# Consultas 1, 2, 3 são consultas com parâmetro

    if(num == 1):
        botao_uber_x = ttk.Button(frame, text="Uber X", command=lambda: RealizarConsultaParametro(num, "Uber X"))
        botao_uber_x.grid(row=5, column=2, padx=10, pady=5)

        botao_uber_black = ttk.Button(frame, text="Uber Black", command=lambda: RealizarConsultaParametro(num, "Uber Black"))
        botao_uber_black.grid(row=6, column=2, padx=10, pady=5)

        botao_uber_flash = ttk.Button(frame, text="Uber Flash", command=lambda: RealizarConsultaParametro(num, "Uber Flash"))
        botao_uber_flash.grid(row=7, column=2, padx=10, pady=5)
    
    elif(num == 2):
        label_dias = ttk.Label(frame, text="Digite o número de dias:")
        label_dias.grid(row=4, column=2, padx=10, pady=5)

        entrada = tk.StringVar()

        caixa_texto = ttk.Entry(frame, textvariable=entrada)
        caixa_texto.grid(row=5, column=2, padx=10, pady=5)

        botao_consultar = ttk.Button(frame, text="Consultar", command=lambda: RealizarConsultaParametro(num, entrada.get()))
        botao_consultar.grid(row=6, column=2, padx=10, pady=5)
    

    elif(num == 3):
        label_avaliacao = ttk.Label(frame, text="Digite a avaliação mínima:")
        label_avaliacao.grid(row=4, column=2, padx=10, pady=5)

        entrada = tk.StringVar()

        caixa_texto = ttk.Entry(frame, textvariable=entrada)
        caixa_texto.grid(row=5, column=2, padx=10, pady=5)

        botao_consultar = ttk.Button(frame, text="Consultar", command=lambda: RealizarConsultaParametro(num, entrada.get()))
        botao_consultar.grid(row=6, column=2, padx=10, pady=5)


# O restante das consultas não são feitas com parâmetros

    elif(num == 4):
        consulta = f'SELECT nro_celular_cliente, count(nome_categoria) CORRIDASUBERX \
                    FROM Clientes_Cartoes \
                    NATURAL JOIN Viagens \
                    LEFT JOIN motoristasuberx \
                    ON Viagens.nro_celular_motorista = motoristasuberx.nro_celular_motorista \
                    GROUP BY nro_celular_cliente;'
        
        cursor.execute(consulta)
        resultado = cursor.fetchall()

        tabela = ttk.Treeview(frame, columns=("nro_celular_cliente", "CORRIDASUBERX"), show="headings")
        tabela.heading("nro_celular_cliente", text="Número de celular do cliente")
        tabela.heading("CORRIDASUBERX", text="Número de viagens Uber X")
        tabela.grid(row=0, column=2, rowspan=12, padx=10, pady=5)

        # Insere os resultados da consulta na tabela
        for i in resultado:
            tabela.insert("", "end", values=i)

    elif(num == 5):
        consulta = f'SELECT Pessoas.nome AS VIP, Clientes_Cartoes.nro_celular_cliente,  count(Viagens.preco) AS numero_viagens \
                    FROM Clientes_Cartoes \
                    JOIN Pessoas ON Pessoas.nro_celular = Clientes_Cartoes.nro_celular_cliente \
                    JOIN Viagens ON Clientes_Cartoes.nro_celular_cliente = Viagens.nro_celular_cliente \
                    GROUP BY Clientes_Cartoes.nro_celular_cliente \
                    HAVING numero_viagens >= 2;'
        
        cursor.execute(consulta)
        resultado = cursor.fetchall()

        tabela = ttk.Treeview(frame, columns=("VIP", "nro_celular_cliente", "numero_viagens"), show="headings")
        tabela.heading("VIP", text="Nome do cliente VIP")
        tabela.heading("nro_celular_cliente", text="Número de celular do cliente")
        tabela.heading("numero_viagens", text="Número de viagens")
        tabela.grid(row=0, column=2, rowspan=12, padx=10, pady=5)

        for i in resultado:
            tabela.insert("", "end", values=i)
        
    elif(num == 6):
        consulta = f'SELECT pc.nro_celular_cliente, COUNT(pc.nome_cupom) AS numero_cupons, viagens_cliente.qtde_viagens \
                    FROM PossesCupons pc \
                    INNER JOIN ( \
                    SELECT v.nro_celular_cliente, COUNT(*) as qtde_viagens \
                    FROM Viagens v \
                    GROUP BY v.nro_celular_cliente) \
                    as viagens_cliente ON pc.nro_celular_cliente = viagens_cliente.nro_celular_cliente \
                    GROUP BY pc.nro_celular_cliente;' 
        
        cursor.execute(consulta)
        resultado = cursor.fetchall()

        tabela = ttk.Treeview(frame, columns=("nro_celular_cliente", "numero_cupons", "numero_viagens"), show="headings")
        tabela.heading("nro_celular_cliente", text="Número de celular do cliente")
        tabela.heading("numero_cupons", text="Número de cupons")
        tabela.heading("numero_viagens", text="Número de viagens")
        tabela.grid(row=0, column=2, rowspan=12, padx=10, pady=5)

        for i in resultado:
            tabela.insert("", "end", values=i)

    elif(num == 7):
        consulta = f'SELECT nome, DATEDIFF(NOW(), ult) AS TEMPO \
                    FROM (SELECT nro_celular_cliente, MAX(data_viagem) AS ult \
	                    FROM viagens \
                        GROUP BY nro_celular_cliente) AS ultima_viagem \
                    INNER JOIN clientes_cartoes ON clientes_cartoes.nro_celular_cliente = ultima_viagem.nro_celular_cliente \
                    INNER JOIN pessoas ON clientes_cartoes.nro_celular_cliente = pessoas.nro_celular;'
            
        cursor.execute(consulta)
        resultado = cursor.fetchall()

        tabela = ttk.Treeview(frame, columns=("nome", "TEMPO"), show="headings")
        tabela.heading("nome", text="Nome do cliente")
        tabela.heading("TEMPO", text="Dias desde sua última viagem")
        tabela.grid(row=0, column=2, rowspan=12, padx=10, pady=5)

        for i in resultado:
            tabela.insert("", "end", values=i)
        
    elif(num == 8):
        consulta = f'SELECT nome AS usuario_inativo, nro_celular \
                    FROM Pessoas INNER JOIN Clientes_Cartoes c ON Pessoas.nro_celular = c.nro_celular_cliente \
                    WHERE NOT EXISTS ( \
                        SELECT * \
                        FROM Viagens \
                        WHERE Viagens.nro_celular_cliente = c.nro_celular_cliente);'

        cursor.execute(consulta)
        resultado = cursor.fetchall()

        tabela = ttk.Treeview(frame, columns=("usuario_inativo", "nro_celular"), show="headings")
        tabela.heading("usuario_inativo", text="Nome do cliente")
        tabela.heading("nro_celular", text="Número de celular")
        tabela.grid(row=0, column=2, rowspan=12, padx=10, pady=5)

        for i in resultado:
            tabela.insert("", "end", values=i)
        
    elif(num == 9):
        consulta = f'  SELECT codigo_viagem \
                       FROM viagens V \
                       WHERE nro_celular_cliente IN (SELECT nro_celular_cliente \
				                                    FROM clientes_cartoes NATURAL JOIN reclamacoes R \
									                WHERE resposta IS NULL AND V.data_viagem = R.data_reclamacao);'
        cursor.execute(consulta)
        resultado = cursor.fetchall()

        tabela = ttk.Treeview(frame, columns=("codigo_viagem"), show="headings")
        tabela.heading("codigo_viagem", text="Código da viagem")
        tabela.grid(row=0, column=2, rowspan=12, padx=10, pady=5)

        for i in resultado:
            tabela.insert("", "end", values=i)

    elif(num == 10):
        consulta = f'SELECT nome, nro_celular_cliente \
                    FROM clientes_cartoes C JOIN pessoas ON C.nro_celular_cliente = pessoas.nro_celular \
                    WHERE nro_celular_cliente IN (SELECT nro_celular_motorista \
								                  FROM motoristas M \
                                                  WHERE M.nro_celular_motorista = C.nro_celular_cliente);'

        cursor.execute(consulta)
        resultado = cursor.fetchall()

        tabela = ttk.Treeview(frame, columns=("nome", "nro_celular"), show="headings")
        tabela.heading("nome", text="Nome do cliente")
        tabela.heading("nro_celular", text="Número de celular")
        tabela.grid(row=0, column=2, rowspan=12, padx=10, pady=5)

        for i in resultado:
            tabela.insert("", "end", values=i)
    
        # Acionando o trigger
    elif(num == 11):
        consulta = f'SELECT nro_celular_cliente FROM reservas'
        cursor.execute(consulta)
        resultado = cursor.fetchall()

        tabela = ttk.Treeview(frame, columns=('1'), show="headings")
        tabela.heading('1', text="Clientes com reserva (ANTES)")
        tabela.grid(row=0, column=2, rowspan=12, padx=10, pady=5)

        for i in resultado:
            tabela.insert("", "end", values=i)

        # Executa um delete na tabela Clientes_Cartoes para testar o trigger
        cursor.execute("DELETE FROM Clientes_Cartoes WHERE nro_celular_cliente = '5511894855212'")

        # confirma as mudanças no banco de dados
        conexao.commit()

        consulta = f'SELECT nro_celular_cliente FROM reservas'
        cursor.execute(consulta)
        resultado = cursor.fetchall()

        tabela = ttk.Treeview(frame, columns=('1'), show="headings")
        tabela.heading('1', text="Clientes com reserva (DEPOIS)")
        tabela.grid(row=0, column=3, rowspan=12, padx=10, pady=5)

        for i in resultado:
            tabela.insert("", "end", values=i)


# Define textos que ficam ao lado dos botões de consulta com a finalidade de descrever a consulta
def DefinirTextoDescritivo(num):

    if(num == 1):
        return 'Dado o nome da categoria, mostra os motoristas que mais realizaram \
corridas nessa categoria em ordem decrescente.'

    elif(num == 2):
        return 'Dado um número x, retorna os cupons que foram utilizados mais de uma \
vez nos últimos x dias.'

    elif(num == 3):
        return 'Dado uma avalição x, entre 0 e 5, retorna o nome e número dos clientes que não fizeram viagens \
com motoristas com menos que x estrelas e nunca realizaram uma reclamação.'

    elif(num == 4):
        return 'Número de viagens que cada cliente que utiliza Uber X realizou.'
    
    elif(num == 5):
        return 'Nome dos clientes VIP do aplicativo (Número de viagens >= 2).'
    
    elif(num == 6):
        return 'Número dos clientes que possuem cupons e o número de viagens realizadas por \
esses clientes.'

    elif(num == 7):
        return 'Número de celular do cliente o número de dias passados desde sua última viagem com a Uber.'

    elif(num == 8):
        return 'Nome dos usuários que nunca fizeram uma viagem no aplicativo.'

    elif(num == 9):
        return 'Código de todas as viagens as quais não foram respondidas as reclamações sobre esa viagem.'

    elif(num == 10):
        return 'Nome dos usuários que são clientes e motoristas no aplicativo Uber.'

# Código Main

conexao = mysql.connector.connect(
    host='localhost',
    user='root',
    password='password',
    database='uber',
)

tabela_existe = False
cursor = conexao.cursor()

# cria a janela
janela = tk.Tk()
janela.title("Trabalho Etapa III")
frame = tk.Frame(janela)

frame.columnconfigure(0, minsize=150)
frame.columnconfigure(1, minsize=100)

for i in range(11):
    # Definindo botões de consulta
    botao = tk.Button(frame, text=f"Consulta {i+1}", command=lambda num=i+1: RealizarConsulta(num))
    botao.grid(row=i, column=0, padx=10, pady=5)

    texto_descritivo = tk.Label(frame, text=DefinirTextoDescritivo(i+1))
    texto_descritivo.grid(row=i, column=1, sticky="w", padx=10, pady=5)

# Definindo botão para disparar gatilho
botao = tk.Button(frame, text=f"Disparar gatilho", command=lambda num=i+1: RealizarConsulta(11))
botao.grid(row=i, column=0, padx=10, pady=5)

texto_descritivo = tk.Label(frame, text=DefinirTextoDescritivo(11))
texto_descritivo.grid(row=i, column=1, sticky="w", padx=10, pady=5)

frame.pack()

janela.mainloop()

cursor.close()
conexao.close()