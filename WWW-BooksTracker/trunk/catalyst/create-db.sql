-- Create the main table.
CREATE TABLE books (
    id integer primary key,
    title varchar(1000),
    url varchar(4000),
    -- Perhaps make a separate table for authors with 1->Many
    -- relationship here.
    authors varchar(2000),
    original_lang integer,
    license integer,
    abstract text,
    year integer,
    publisher varchar(500),
    isbn varchar(40),
    last_updated timestamp
);

CREATE SEQUENCE books_id NO MAXVALUE START WITH 1 ;

CREATE TABLE formats (
    id integer primary key,
    label varchar(500),
    description text
);

CREATE SEQUENCE formats_id_seq NO MAXVALUE START WITH 1 ;

CREATE TABLE books_formats (
    id bigint primary key,
    book int,
    format int
);

CREATE SEQUENCE books_formats_id_seq NO MAXVALUE START WITH 1 ;

CREATE TABLE languages (
    id integer primary key,
    name varchar(100)
);

CREATE SEQUENCE languages_id_seq NO MAXVALUE START WITH 1 ;

CREATE TABLE translations (
    id bigint primary key,
    language integer,
    book integer
);

CREATE SEQUENCE translations_id_seq NO MAXVALUE START WITH 1 ;

CREATE TABLE licenses (
    id integer,
    name varchar(500),
    description text
);

CREATE SEQUENCE licenses_id_seq NO MAXVALUE START WITH 1;

