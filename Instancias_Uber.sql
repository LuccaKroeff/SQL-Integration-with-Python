DROP DATABASE Uber;
CREATE DATABASE Uber;
USE Uber;

CREATE TABLE Pessoas (
	nro_celular CHAR(13) PRIMARY KEY,
    email VARCHAR(60) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    senha VARCHAR(80) NOT NULL
);

INSERT INTO Pessoas (nro_celular, email, nome, senha) VALUES
	('5551999891230', 'user1@gmail.com', 'Taylor Swift', 'twentytwo'),
    ('5511894855212', 'user2@gmail.com', 'Claúdia Aparecida', 'claudiazinha'),
    ('5521904394202', 'user3@gmail.com',  'Jorge Amado', '1234amado'),
    ('5543990975445', 'user4@gmail.com', 'Alan Patrick de Oliveira', 'ehointer'),
    ('5521989392312', 'user5@gmail.com', 'Luís Ferreira Silva', 'minecraft'),
    ('5551993264092', 'user6@gmail.com',  'Matheus Goulart', 'mineiro'),
	('5554963781923', 'user7@gmail.com',  'Maria Joao Couto', 'portugallo'),
    ('5441892932981', 'user8@gmail.com',  'Luka Modric', 'filho123'),
    ('5551995718860', 'user9@gmail.com',  'Alberto Perez', 'codigo213');
    
CREATE TABLE Clientes_Cartoes(
	nro_celular_cliente CHAR(13) PRIMARY KEY,
	nro_cartao CHAR(16),
    titular VARCHAR(100) NOT NULL,
    cvv CHAR(3) NOT NULL,
    validade CHAR(5) NOT NULL,
	avaliacao DECIMAL(3,2),
    FOREIGN KEY (nro_celular_cliente) REFERENCES Pessoas (nro_celular)
);

INSERT INTO Clientes_Cartoes(nro_celular_cliente, nro_cartao, titular, cvv, validade, avaliacao) VALUES
	('5551999891230', '4032103345678900', 'TAYLOR A SWIFT', '423', '10/29', 5.00),
    ('5511894855212', '8499343722234555',  'CLAUDIA B APARECIDA', '199', '06/31', 4.00),
    ('5521904394202', '9233010195569332',  'GUILHERME JUNIOR ABREU', '980', '01/25', 4.25),
    ('5441892932981', '7312837191298312', 'LUKA V MODRIC', '172', '05/27', 4.93),
    ('5551995718860', '9102014382562817', 'ALERTO B PEREZ', 433, '04/30', null);
    
    
CREATE TABLE Categorias (
	nome_categoria VARCHAR(20) PRIMARY KEY
);

INSERT INTO Categorias (nome_categoria) VALUES
	('Uber Black'),
    ('Uber Flash'),
    ('Uber X');
    
        
CREATE TABLE Motoristas (
	nro_celular_motorista CHAR(13) PRIMARY KEY,
    placa CHAR(7) UNIQUE NOT NULL,
    conta_bancaria VARCHAR(20) NOT NULL,
    carteira_valida BOOL NOT NULL,
    modelo_veiculo VARCHAR(40) NOT NULL,
    categoria_motorista VARCHAR(20) NOT NULL,
    avaliacao DECIMAL(3,2),
    FOREIGN KEY (nro_celular_motorista) REFERENCES Pessoas (nro_celular),
    FOREIGN KEY (categoria_motorista) REFERENCES Categorias (nome_categoria)
);

INSERT INTO Motoristas (nro_celular_motorista, placa, conta_bancaria, carteira_valida, modelo_veiculo, categoria_motorista, avaliacao) VALUES
	('5543990975445', 'IVH1R23', '11122234554', true, 'Ford Focus', 'Uber X', 4.98),
    ('5521989392312', 'JVQ1T99', '20940394', true, 'Honda HRV', 'Uber Black', 4.5),
    ('5551993264092', 'LPZ5J12', '05493954', true, 'Honda Civic', 'Uber Flash', 4.96),
    ('5554963781923', 'ITG8764', '917238291', true, 'Volkswagen Polo', 'Uber X', null),
    ('5441892932981', 'LOB2461', '723628274', true, 'VMW 320', 'Uber X', 4.95),
    ('5511894855212', 'CLA3126', '8499343722234555', true, 'Ford 3829', 'Uber Black', 4.94);
    
CREATE TABLE Reclamacoes (
	codigo_reclamacao CHAR(7) PRIMARY KEY,
    mensagem TEXT NOT NULL,
    resposta TEXT,
    data_reclamacao DATETIME NOT NULL,
    nro_celular_cliente CHAR(13) NOT NULL,
    FOREIGN KEY (nro_celular_cliente) REFERENCES Clientes_Cartoes (nro_celular_cliente)
);

INSERT INTO Reclamacoes (codigo_reclamacao, mensagem, resposta, data_reclamacao, nro_celular_cliente) VALUES
	(0239431, 'Não consigo adicionar um cartão', 'Conseguimos resolver seu problema', '2021-01-05 13:00:00', '5551999891230'),
	(8439290, 'Foi cobrado em duplicidade!', 'Seu valor foi ressarcido', '2015-05-05 23:14:04', '5511894855212'),
    (4329395, 'Meu cupom está dando erro', null , '2022-09-12 8:00:00', '5441892932981');
    
CREATE TABLE Cupons (
	nome VARCHAR(20) PRIMARY KEY,
    desconto TINYINT NOT NULL,
    CHECK (desconto between 0 and 100)
);

INSERT INTO Cupons (nome, desconto) VALUES
	('10%OFF', 10),
    ('BLACKFRIDAY25', 25),
    ('DIADOSNAMORADOS35', 35);

CREATE TABLE Reservas (
	codigo_reserva CHAR(8) PRIMARY KEY,
    data_reserva DATETIME NOT NULL,
    nro_celular_cliente CHAR(13) NOT NULL,
    origem VARCHAR(70) NOT NULL,
    destino VARCHAR(70) NOT NULL,
    FOREIGN KEY (nro_celular_cliente) REFERENCES Clientes_Cartoes (nro_celular_cliente)
);

INSERT INTO Reservas (codigo_reserva, data_reserva, nro_celular_cliente, origem, destino) VALUES
	('20307041', '2023-02-04 14:00:00', '5511894855212', 'Protásio Alves 234', 'Carazinho 312'),
    ('00128331', '2023-03-03 01:20:00', '5551999891230', 'Ramiro Barcelos 34', 'Campus do Vale'),
    ('49329231', '2023-09-10 20:35:00', '5521904394202', 'Getulio Vargas 31', 'Ipiranga 232');
    
CREATE TABLE Viagens (
	codigo_viagem CHAR(8) PRIMARY KEY,
	data_viagem DATETIME NOT NULL,
	preco FLOAT NOT NULL,
    origem VARCHAR(70) NOT NULL,
    destino VARCHAR(70) NOT NULL,
    nro_celular_cliente CHAR(13) NOT NULL,
    nro_celular_motorista CHAR(13) NOT NULL,
    FOREIGN KEY (nro_celular_cliente) REFERENCES Clientes_Cartoes (nro_celular_cliente),
    FOREIGN KEY (nro_celular_motorista) REFERENCES Motoristas (nro_celular_motorista)
);

INSERT INTO Viagens (codigo_viagem, data_viagem, preco, origem, destino, nro_celular_cliente, nro_celular_motorista) VALUES
	('19503202','2022-12-05 10:15:00', 17.35, 'Salvador Dali 232', 'Iguapo 430', '5551999891230', '5521989392312'),
    ('19394321','2023-03-26 10:15:00', 45.95, 'Iguapo 430', 'Aeroporto Salgado Filho', '5551999891230', '5551993264092'),
    ('27492031','2023-01-01 4:56:00', 34.87, 'Fabio de Barros 291', 'Getulio Vargas 2391', '5511894855212' , '5543990975445'),
    ('30530040','2006-09-10 17:40:00', 10.12, 'Andradas 50', 'Bordini 340', '5521904394202','5551993264092'),
    ('83128901','2022-09-12 8:00:00', 07.10, 'Ipiranga 20', 'Mc Donalds Silva Só', '5441892932981', '5554963781923'),
    ('89841841','2022-08-01 15:30:00', 16.20, 'Campus UFRGS', 'Parcão', '5521904394202','5441892932981'),
    ('72019001','2022-01-11 20:30:00', 30.40, 'Parque Redenção', 'Francisco Ferrer 40', '5551999891230','5441892932981'),
    ('11182381','2022-04-05 10:15:00', 20.80, 'Avenida Paraguacu 2891', 'Complex', '5441892932981', '5441892932981'),
    ('23421841','2023-03-25 4:10:00', 35.27, 'Avenida Paraguacu 21', 'Graciliano Ramos 98', '5441892932981', '5521989392312');
    
CREATE TABLE PossesCupons (
	nro_celular_cliente CHAR(13) NOT NULL,
    nome_cupom VARCHAR(20) NOT NULL,
    validade TINYINT,
    codigo_viagem CHAR(8),
	FOREIGN KEY (nro_celular_cliente) REFERENCES Clientes_Cartoes (nro_celular_cliente),
    FOREIGN KEY (nome_cupom) REFERENCES Cupons (nome),
    FOREIGN KEY (codigo_viagem) references Viagens (codigo_viagem),
    PRIMARY KEY(nro_celular_cliente, nome_cupom)
);

INSERT INTO PossesCupons (nro_celular_cliente, nome_cupom, validade, codigo_viagem) VALUES
	('5551999891230', 'BLACKFRIDAY25', 3, '19503202'),
    ('5551999891230', 'DIADOSNAMORADOS35', 10, '19394321'),
    ('5521904394202', 'BLACKFRIDAY25', NULL, NULL),
    ('5521904394202', 'DIADOSNAMORADOS35', 20, '23421841');
    
    
 




