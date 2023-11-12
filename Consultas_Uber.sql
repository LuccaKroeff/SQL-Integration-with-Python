-- Manipulação da Base de Dados: Consultas, Visões, Gatilhos
-- DROP trigger excluir_reservas_cupons_reclamacoes_viagens;
-- DROP view MOTORISTASUBERX;

-- DEFININDO 10 CONSULTAS ÚTEIS COM O USO DE NO MÍNIMO 3 TABELAS

-- ------------------------------------------------------------------------------------------------------
-- VISÃO: como o mais comum é pedirmos em uma corrida a categoria Uber X, vamos criar uma visão para 
-- facilitar o acesso a essa informação ao usuário.
CREATE view MOTORISTASUBERX 
AS SELECT pessoas.nome, motoristas.nro_celular_motorista, motoristas.placa, motoristas.conta_bancaria, motoristas.carteira_valida, motoristas.modelo_veiculo, categorias.nome_categoria
FROM motoristas 
LEFT JOIN categorias ON motoristas.categoria_motorista = categorias.nome_categoria
INNER JOIN pessoas ON motoristas.nro_celular_motorista = pessoas.nro_celular
WHERE nome_categoria = 'Uber X'
GROUP BY motoristas.nro_celular_motorista;

SELECT * FROM MOTORISTASUBERX;

-- ------------------------------------------------------------------------------------------------------
-- CONSULTA QUE UTILIZA A VISÃO DEFINIDA

 -- Nos diz o número de viagens que cada cliente que utiliza Uber X realizou.
 -- Justificativa: Por ser uma categoria muito usualmente utilizada, pode ser importante para empresa
 -- manter informação sobre a quantidade de vezes que cada cliente utilizou a categoria Uber X.
SELECT nro_celular_cliente, count(nome_categoria) CORRIDASUBERX
FROM Clientes_Cartoes 
NATURAL JOIN Viagens 
LEFT JOIN motoristasuberx ON Viagens.nro_celular_motorista = motoristasuberx.nro_celular_motorista
GROUP BY nro_celular_cliente;

-- ------------------------------------------------------------------------------------------------------
-- SEGUNDA CONSULTA QUE UTILIZA A VISÃO DEFINIDA

-- Nome de todos os motoristas que fizeram corridas na categoria Uber X, com o número de viagens ordenada
-- de forma decrescente. 
-- Justificativa: Como já dito anteriormente, essa se trata da categoria de maior relevância dentro da 
-- Uber, e por isso pode ser interessante guardamos a informação da quantidade de viagens que cada motorista
-- realizou.
SELECT nome, v.nro_celular_motorista, COUNT(*) AS total_corridas
FROM Viagens v
JOIN MOTORISTASUBERX m ON v.nro_celular_motorista = m.nro_celular_motorista
GROUP BY v.nro_celular_motorista
ORDER BY total_corridas DESC;

-- ------------------------------------------------------------------------------------------------------
-- CONSULTA QUE É RESPONDIDA COM A CLÁUSULA GROUP BY

-- Nome dos cupons que foram utilizados mais que 1 vez na última semana pelos usuários do aplicativo Uber
-- Justificativa: Deve ser interessante para uma empresa como a Uber ter a informação dos cupons que estão
-- sendo mais utilizados nos últimos dias, uma vez que essa informação pode ajudar em campanhas de marketing.
SELECT nome_cupom, COUNT(*) AS vezes_utilizado
FROM PossesCupons
JOIN Viagens ON PossesCupons.codigo_viagem = Viagens.codigo_viagem
WHERE data_viagem BETWEEN '2023-03-20' AND '2023-03-27'
GROUP BY nome_cupom
HAVING vezes_utilizado >= 2
ORDER BY vezes_utilizado DESC;

-- ------------------------------------------------------------------------------------------------------
-- CONSULTA QUE É RESPONDIDA COM A CLÁUSULA GROUP BY
-- (ESTA USANDO HAVING)

-- Nome dos clientes que fizeram 2 viagens ou mais no aplicativo uber e por isso são considerados VIPs.
-- SIMPLIFICAÇÃO: No mundo real, um cliente se torna VIP quando alcança um número de viagens superior a 
-- 10 viagens no mês, aqui consideramos  apenas 2 viagens durante o período inteiro de uso do aplicativo.
-- Justificativa: Justamente pelo fato de que a Uber traz benefícios para aqueles clientes que realizam
-- mais viagens em seu aplcativa, torna-se de imensa importância essa consulta.
SELECT Pessoas.nome AS VIP, Clientes_Cartoes.nro_celular_cliente,  count(Viagens.preco) AS numero_viagens
FROM Clientes_Cartoes 
JOIN Pessoas ON Pessoas.nro_celular = Clientes_Cartoes.nro_celular_cliente
JOIN Viagens ON Clientes_Cartoes.nro_celular_cliente = Viagens.nro_celular_cliente
GROUP BY Clientes_Cartoes.nro_celular_cliente
HAVING numero_viagens >= 2;


-- ------------------------------------------------------------------------------------------------------
-- CONSULTA QUE NECESSITA DE SUBCONSULTAS

-- Seleciona todos aqueles clientes que possuem pelo menos um cupom e indica seu número de cupons e o 
-- número de viagens que esse cliente realizou.
-- Justificativa: Pode ser interessante para empresa manter informações sobre o número de cupons dos
-- clientes e o número de viagens que ele realizou, uma vez que as empresas tendem a dar mais cupons
-- para aqueles clientes mais ativos e para aqueles que não possuem um grande número de cupons.
SELECT pc.nro_celular_cliente, COUNT(pc.nome_cupom) AS numero_cupons, viagens_cliente.qtde_viagens
FROM PossesCupons pc
INNER JOIN (
    SELECT v.nro_celular_cliente, COUNT(*) as qtde_viagens
    FROM Viagens v
    GROUP BY v.nro_celular_cliente
) as viagens_cliente ON pc.nro_celular_cliente = viagens_cliente.nro_celular_cliente
GROUP BY pc.nro_celular_cliente;

-- ------------------------------------------------------------------------------------------------------
-- CONSULTA QUE NECESSITA DE SUBCONSULTAS

-- Mostra um número de celular de um cliente e os números de dias desde a última vez que fez uma corrida
-- com a Uber.
-- Justificativa: É importante para Uber saber a última vez que os usuários usaram o aplicativo.
select nome, DATEDIFF(NOW(), ult) as TEMPO
from (select nro_celular_cliente, MAX(data_viagem) as ult
	  from viagens
      group by nro_celular_cliente) as ultima_viagem
      inner join clientes_cartoes on clientes_cartoes.nro_celular_cliente = ultima_viagem.nro_celular_cliente 
      inner join pessoas on clientes_cartoes.nro_celular_cliente = pessoas.nro_celular;
        

-- ------------------------------------------------------------------------------------------------------
-- CONSULTA QUE DEVE SER RESPONDIDA COM NOT EXISTS

-- Clientes que não correram com NENHUM motorista que tivesse menos de 4.95 estrelas na avaliação nem 
-- possui NENHUMA reclamacao
-- Justificativa: Ter essa informação é importante para controle de qualidade do aplicativo.
select distinct nome, nro_celular_cliente
from clientes_cartoes C join pessoas on C.nro_celular_cliente = pessoas.nro_celular
where not exists (select *
				  from viagens V natural join motoristas
                  where C.nro_celular_cliente = V.nro_celular_cliente and motoristas.avaliacao < 4.95)
and not exists (select *
				from reclamacoes R
                where R.nro_celular_cliente = C.nro_celular_cliente);
    
-- ------------------------------------------------------------------------------------------------------
-- OUTRAS CONSULTAS

-- Nome dos usuários que NUNCA fizeram uma viagem no aplicativo Uber.
-- Justificativa: É importante para empresa Uber saber o número de usuários que estão cadastrados no
-- aplicativo, mas nunca realizaram uma corrida. Informações como essa podem acarretar em decisões 
-- dentro da empresa sobre manter ou não a conta desses usuários em seu servidor.
SELECT nome AS usuario_inativo, nro_celular
FROM Pessoas
INNER JOIN Clientes_Cartoes c ON Pessoas.nro_celular = c.nro_celular_cliente
WHERE NOT EXISTS (
    SELECT *
    FROM Viagens
    WHERE Viagens.nro_celular_cliente = c.nro_celular_cliente
);


-- ------------------------------------------------------------------------------------------------------
-- OUTRAS CONSULTAS

-- Seleciona todas as viagens que não receberam resposta de uma reclamação.
-- Justificativa: É interessante para empresa saber as reclamações que ainda não foram respondidas com
-- a finalidade de atendê-las o mais rápido possível.
  SELECT codigo_viagem
  FROM viagens V
  WHERE nro_celular_cliente IN (SELECT nro_celular_cliente
									FROM clientes_cartoes NATURAL JOIN reclamacoes R
									WHERE resposta IS NULL AND V.data_viagem = R.data_reclamacao);
                                    
-- ------------------------------------------------------------------------------------------------------
-- OUTRAS CONSULTAS 

-- Seleciona o nome e número de celular das pessoas que são tanto clientes quanto motoristas.
-- Justificativa: É interessante para empresa saber todos aqueles clientes que são também motoristas,
-- assim, ela pode ter uma noção melhor da densidade clientes / motoristas, algo muito útil.
  SELECT nome, nro_celular_cliente
  FROM clientes_cartoes C JOIN pessoas ON C.nro_celular_cliente = pessoas.nro_celular
  WHERE nro_celular_cliente IN (SELECT nro_celular_motorista
								FROM motoristas M
                                WHERE M.nro_celular_motorista = C.nro_celular_cliente);
      
-- ------------------------------------------------------------------------------------------------------
-- GATILHO: Caso um cliente seja excluído, exclui todos os cupons que estavam em posse desse cliente,
-- e exclui todas as reservas que esse cliente realizou.
DELIMITER $$
CREATE TRIGGER excluir_reservas_cupons_reclamacoes_viagens BEFORE DELETE ON Clientes_Cartoes
FOR EACH ROW
BEGIN
    CALL nome(OLD.nro_celular_cliente);
END $$

CREATE PROCEDURE nome(IN nro_celular_cliente_param VARCHAR(20))
BEGIN
    DELETE FROM Reservas WHERE nro_celular_cliente = nro_celular_cliente_param;
    DELETE FROM PossesCupons WHERE nro_celular_cliente = nro_celular_cliente_param;
    DELETE FROM Reclamacoes WHERE nro_celular_cliente = nro_celular_cliente_param;
    DELETE FROM Viagens WHERE nro_celular_cliente = nro_celular_cliente_param;
END $$
DELIMITER ;

-- Abaixo encontra-se consultas comentadas para verificar a funcionalidade do TRIGGER.

-- SELECT * FROM reservas;
-- SELECT * FROM possescupons;
-- SELECT * FROM reclamacoes;
-- SELECT * FROM viagens;

-- DELETE FROM Clientes_Cartoes
-- WHERE nro_celular_cliente = '5551999891230';

-- SELECT * FROM reservas;
-- SELECT * FROM possescupons;
-- SELECT * FROM reclamacoes;
-- SELECT * FROM viagens;