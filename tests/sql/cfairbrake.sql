
DROP TABLE users;

CREATE TABLE users (
 userid INT NOT NULL GENERATED ALWAYS AS IDENTITY,
 firstname VARCHAR(50),
 lastname VARCHAR(50)
);

INSERT INTO users ( firstname, lastname ) VALUES ( 'Inigo', 'Montoya' );

INSERT INTO users ( firstname, lastname ) VALUES ( 'Jason', 'Gideon') ;

INSERT INTO users ( firstname, lastname ) VALUES ( 'Saul', 'Berenson' );