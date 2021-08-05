-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2021-05-17 13:07:29.238

-- tables
-- Table: GRUPO
CREATE TABLE GR20_GRUPO (
    nro_grupo int  NOT NULL,
    nombre_grupo varchar(40)  NOT NULL,
    limite_integrantes int  NOT NULL,
    tipo_gr char(1)  NOT NULL,
    CONSTRAINT PK_GR20_GRUPO PRIMARY KEY (nro_grupo)
);

-- Table: GR_COMUN
CREATE TABLE GR20_GR_COMUN (
    nro_grupo int  NOT NULL,
    caracteristica varchar(30)  NOT NULL,
    CONSTRAINT PK_GR20_GR_COMUN PRIMARY KEY (nro_grupo)
);

-- Table: GR_EXCLUSIVO
CREATE TABLE GR20_GR_EXCLUSIVO (
    nro_grupo int  NOT NULL,
    perfil varchar(30)  NOT NULL,
    CONSTRAINT PK_GR20_GR_EXCLUSIVO PRIMARY KEY (nro_grupo)
);

-- Table: INTEGRA
CREATE TABLE GR20_INTEGRA (
    tipo_usuario char(3),
    cod_usuario int  NOT NULL,
    nro_grupo int  NOT NULL,
    fecha date  NOT NULL,
    CONSTRAINT PK_GR20_INTEGRA PRIMARY KEY (tipo_usuario,cod_usuario,nro_grupo)
);

-- Table: USUARIO
CREATE TABLE GR20_USUARIO (
    tipo_usuario char(3)  NOT NULL,
    cod_usuario int  NOT NULL,
    apellido varchar(30)  NOT NULL,
    nombre varchar(30)  NOT NULL,
    nick varchar(15)  NULL,
    CONSTRAINT PK_GR20_USUARIO PRIMARY KEY (tipo_usuario,cod_usuario)
);

-- foreign keys
-- Reference: FK_GR_COMUN_GRUPO (table: GR_COMUN)
ALTER TABLE GR20_GR_COMUN ADD CONSTRAINT FK_GR20_GR_COMUN_GRUPO
    FOREIGN KEY (nro_grupo)
    REFERENCES GR20_GRUPO (nro_grupo)
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_GR_EXCLUSIVO_GRUPO (table: GR_EXCLUSIVO)
ALTER TABLE GR20_GR_EXCLUSIVO ADD CONSTRAINT FK_GR20_GR_EXCLUSIVO_GRUPO
    FOREIGN KEY (nro_grupo)
    REFERENCES GR20_GRUPO (nro_grupo)
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_INTEGRA_GRUPO (table: INTEGRA)
ALTER TABLE GR20_INTEGRA ADD CONSTRAINT FK_GR20_INTEGRA_GRUPO
    FOREIGN KEY (nro_grupo)
    REFERENCES GR20_GRUPO (nro_grupo)
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_INTEGRA_USUARIO (table: INTEGRA)
ALTER TABLE GR20_INTEGRA ADD CONSTRAINT FK_GR20_INTEGRA_USUARIO
    FOREIGN KEY (tipo_usuario, cod_usuario)
    REFERENCES GR20_USUARIO (tipo_usuario, cod_usuario)
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- End of file.

