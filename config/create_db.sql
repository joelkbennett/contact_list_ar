CREATE TABLE contacts (
  id SERIAL NOT NULL,
  name CHARACTER VARYING(40) NOT NULL,
  email CHARACTER VARYING(40) NOT NULL
);

ALTER TABLE ONLY contacts
  ADD CONSTRAINT contact_pkey PRIMARY KEY(id);

CREATE TABLE phone_numbers(
  id SERIAL NOT NULL,
  label CHARACTER VARYING(40) NOT NULL,
  phone_number CHARACTER VARYING(40) NOT NULL,
  contact_id INTEGER NOT NULL
);

ALTER TABLE ONLY phone_numbers
  ADD CONSTRAINT phone_pkey PRIMARY KEY(id),
  ADD CONSTRAINT contact_fkey FOREIGN KEY(contact_id) REFERENCES contacts(id) ON DELETE CASCADE;

ALTER TABLE ONLY phone_numbers
  DROP CONSTRAINT contact_fkey, 