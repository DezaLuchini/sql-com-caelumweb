SELECT
	turma.id AS "ID",
	curso.codigo AS "Curso",
    sala.nome AS "Sala",
    horario.nome AS "Horário",
	CASE WHEN turma.cidade IS NULL THEN
		CASE WHEN turma.sala_id IS NULL THEN NULL
        ELSE unidade.cidadePadrao END
	ELSE turma.cidade END AS "Cidade",
    CONCAT(turma.primeiroDia,' a ',turma.ultimoDia) AS "Duração",
	responsavel.nome AS "Responsável",
	COUNT(IF(situacaodematricula.nome
		IN ("Confirmado","Reservado","Reposicao", "Aluno cortesia", "Funcionario Caelum", 
        "Aluno teste"),1,NULL)) + CASE WHEN reservasgenericas.numeroDeReservas IS NULL THEN 0
        ELSE reservasgenericas.numeroDeReservas END AS "Total",
    (SELECT instrutor.nome FROM instrutoremaula
		INNER JOIN usuario AS instrutor ON instrutor.id = instrutoremaula.instrutor_id
        WHERE instrutoremaula.turma_id = turma.id LIMIT 1) AS "Instrutor",
    COUNT(IF(situacaodematricula.nome = "Confirmado",1,NULL)) AS "Confirmados",
    COUNT(IF(situacaodematricula.nome = "Reservado",1,NULL)) AS "Reservados",
    COUNT(IF(situacaodematricula.nome 
		IN ("Reposicao", "Aluno cortesia", "Funcionario Caelum", "Aluno teste"),1,NULL)) 
        AS "Reposicao/Aluno cortesia/Funcionario Caelum/Aluno teste",
    COUNT(IF(situacaodematricula.nome="Lista de Espera",1,NULL)) AS "Espera",
    COUNT(IF(situacaodematricula.nome="Interessado",1,NULL)) AS "Interessados",
    reservasgenericas.numeroDeReservas AS "Reserva Genérica",
    sala.limiteDeAlunos-(COUNT(IF(situacaodematricula.nome
		IN ("Confirmado","Reservado","Reposicao", "Aluno cortesia", "Funcionario Caelum", 
        "Aluno teste"),1,NULL)) + CASE WHEN reservasgenericas.numeroDeReservas IS NULL THEN 0
        ELSE reservasgenericas.numeroDeReservas END) AS "Vagas",
	unidade.cidadePadrao AS "Unidade Caelum"
FROM turma
INNER JOIN curso ON curso.id = turma.curso_id
LEFT JOIN sala ON sala.id = turma.sala_id
LEFT JOIN unidade ON unidade.id = sala.unidade_id
LEFT JOIN horario ON horario.id = turma.horario_id
LEFT JOIN usuario AS responsavel ON responsavel.id = turma.atendente_id
LEFT JOIN reservasgenericas ON reservasgenericas.id = turma.reservasGenericas_id
LEFT JOIN matricula ON matricula.turma_id = turma.id
LEFT JOIN situacaodematricula ON situacaodematricula.id = matricula.situacao_id
	AND matricula.ativa = 1
WHERE turma.primeiroDia > "2019-12-10" AND unidade.cidadePadrao = "Sao Paulo"
GROUP BY turma.id
ORDER BY turma.primeiroDia, turma.id