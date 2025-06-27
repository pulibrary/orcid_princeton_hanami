--
-- PostgreSQL rails migration table
--

ALTER TABLE public.schema_migrations ADD COLUMN filename text;

UPDATE public.schema_migrations SET filename='20231009181647_create_users.rb' where version = '20231009181647';
UPDATE public.schema_migrations SET filename='20250206153247_add_university_id_to_users.rb' where version = '20250206153247';
UPDATE public.schema_migrations SET filename='20231010182053_add_email_to_user.rb' where version = '20231010182053';
UPDATE public.schema_migrations SET filename='20250206195504_rolify_create_roles.rb' where version = '20250206195504';
UPDATE public.schema_migrations SET filename='20231011122309_create_tokens.rb' where version = '20231011122309';
