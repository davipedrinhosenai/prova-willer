create table aeronaves(
	id serial primary key,
	modelo varchar(100) not null,
	codigo_cauda varchar(10) unique not null,
	capacidade int not null check(capacidade > 0)
);

create table pilotos(
	id serial primary key,
	nome varchar(100) not null,
	codigo_anac VARCHAR(6) unique not null,
	horas_voo int default 0 check(horas_voo>=0)
);

create table voos(
	id serial primary key,
	aeronaves_id int not null,
	pilotos_id int not null,
	numero_voo varchar(20) not null,
	origem varchar(100) not null,
	destino varchar(100) not null,
	data_hora timestamp not null default current_timestamp,
	status varchar(20) default 'Agendado' check (status in ('Agendado','Em Voo','Concluido','Cancelado')),
	foreign key (aeronaves_id) REFERENCES aeronaves(id),
	foreign key (pilotos_id) REFERENCES pilotos(id)
);

create table passageiros(
	id serial primary key,
	nome varchar(100) not null,
	cpf varchar(11) unique not null,
	email varchar(100) unique not null
);

create table passagens(
	id serial primary key,
	voos_id int not null,
	passageiros_id int not null,
	assento varchar(4) not null,
	classe varchar(20) default 'Economica' check(classe in ('Economica','Executiva')),
	valor decimal(10,2) not null check(valor>0),
	foreign key (voos_id) REFERENCES voos(id),
	foreign key (passageiros_id) REFERENCES passageiros(id)
);

insert into aeronaves (modelo, codigo_cauda, capacidade) VALUES
('BOEING-707','1234567890',200),
('BOEING-707','0987654321',150),
('BOEING-707','1324567894',300),
('BOEING-707','9999999999',400),
('BOEING-707','1111111111',350);

insert into pilotos(nome,codigo_anac,horas_voo) values
('Willer','123456','6767'),
('Davi','654321','67'),
('Guilherme','612534','676'),
('Nicolas','999999','6'),
('Lucca','666666','67676');

insert into passageiros(nome,cpf,email) values
('Manuela','12345678901','manu@email.com'),
('Joao','11111111111','joao@email.com'),
('Miguel','22222222222','miguel@email.com'),
('Othelo','33333333333','othelo@email.com'),
('Nathan','44444444444','nathan@email.com');

insert into voos(aeronaves_id,pilotos_id,numero_voo,origem,destino,data_hora,status) values
(1,1,'AT101','Florianópolis','Sao Paulo','2026-10-05 08:30:00','Agendado')
(2,2,'AT202','Sao Paulo','Varginha','2026-10-01 11:50:00','Em Voo'),
(3,3,'AT303','Fortaleza','São Paulo','2026-10-02 08:30:00','Concluido'),
(4,4,'AT404','Florianópolis','Buenos Aires','2026-06-07 08:30:00','Cancelado'),
(5,5,'AT505','Rio de Janeiro','Belo Horizonte','2026-04-05 08:30:00','Em Voo');

insert into passagens (voos_id,passageiros_id,assento,classe,valor) VALUES
(1,1,'12A','Economica',450.00),
(2,2,'21B','Executiva',1200.00),
(3,3,'67C','Economica',650.00),
(4,4,'28D','Executiva',1500.00),
(5,5,'42E','Economica',500.00);

--Q1
SELECT
	v.numero_voo,
	v.origem,
	v.destino,
	a.modelo,
	p.nome as piloto
from voos v
join aeronaves a ON v.aeronaves_id = a.id
join pilotos p ON v.pilotos_id = p.id
where v.status in ('Agendado','Em Voo');

--Q2
SELECT
	classe,
	sum(valor) as total_arrecadado
from passagens
group by classe;

--Q3
SELECT
	pa.nome as passageiro,
	v.numero_voo,
	ps.assento,
	ps.valor
from passagens ps
join passageiros pa on ps.passageiros_id = pa.id
join voos v on ps.voos_id = v.id
where ps.classe = 'Executiva'
	and ps.valor > 800.00
order by ps.valor DESC

--VIEWS
--VW1
create view vw_painel_aeroporto AS
select
	v.numero_voo,
	v.data_hora,
	v.origem,
	v.destino,
	a.modelo,
	a.codigo_cauda,
	v.status
from voos v
join aeronaves a ON v.aeronaves_id = a.id

--VW2
create view vw_faturamento_por_voo as
select
	v.id as voo_id,
	v.numero_voo,
	v.destino,
	count(ps.id) as quantidade_passageiros,
	coalesce(sum(ps.valor), 0) as receita_total
from voos v
left join passagens ps ON v.id = ps.voos_id
group by v.id, v.numero_voo, v.destino
