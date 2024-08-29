-- Add migration script here
-- if chat changed, notify with chat data
CREATE OR REPLACE FUNCTION add_to_chat()
  RETURNS TRIGGER
  AS $$
BEGIN
  RAISE NOTICE 'add_to_chat: %', NEW;
  PERFORM pg_notify('chat_updated', json_build_object(
    'op', TG_OP,
    'old', OLD,
    'new', NEW
  )::TEXT);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER add_to_chat_trigger
  AFTER INSERT OR UPDATE OR DELETE ON chats
  FOR EACH ROW
  EXECUTE FUNCTION add_to_chat();

-- if new message added, notify with message data
CREATE OR REPLACE FUNCTION add_to_message()
  RETURNS TRIGGER
  AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    RAISE NOTICE 'add_to_message: %', NEW;
    PERFORM
      pg_notify('chat_message_created', row_to_json(NEW)::TEXT);
  END IF;
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER add_to_message_trigger
  AFTER INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION add_to_message();

-- insert 3 workspaces
INSERT INTO workspaces (name, owner_id)
  VALUES ('acme', 0),
  ('foo', 0),
  ('bar', 0);

-- insert 5 users, all with hashed password '123456'
INSERT INTO users(ws_id, email, fullname, password_hash)
  VALUES (1, 'tchen@acme.org', 'Tyr Chen', '$argon2id$v=19$m=19456,t=2,p=1$RiLd1TgnD+v9LMcZt+dvnw$9VwNf/5qdH1vOgqabcH6YoT0gNVZQ4/+JEWEmmUOB4M'),
  (1, 'alice@acme.org', 'Alice Chen', '$argon2id$v=19$m=19456,t=2,p=1$RiLd1TgnD+v9LMcZt+dvnw$9VwNf/5qdH1vOgqabcH6YoT0gNVZQ4/+JEWEmmUOB4M'),
  (1, 'bob@acme.org', 'Bob Chen', '$argon2id$v=19$m=19456,t=2,p=1$RiLd1TgnD+v9LMcZt+dvnw$9VwNf/5qdH1vOgqabcH6YoT0gNVZQ4/+JEWEmmUOB4M'),
  (1, 'charlie@acme.org', 'Charlie Chen', '$argon2id$v=19$m=19456,t=2,p=1$RiLd1TgnD+v9LMcZt+dvnw$9VwNf/5qdH1vOgqabcH6YoT0gNVZQ4/+JEWEmmUOB4M'),
  (1, 'daisy@acme.org', 'Daisy Chen', '$argon2id$v=19$m=19456,t=2,p=1$RiLd1TgnD+v9LMcZt+dvnw$9VwNf/5qdH1vOgqabcH6YoT0gNVZQ4/+JEWEmmUOB4M');

-- insert 4 chats
-- insert public/private channel
INSERT INTO chats (ws_id, name, type, members)
    VALUES (1, 'general', 'public_channel', '{1,2,3,4,5}'),
    (1, 'private', 'private_channel', '{1,2,3}');

-- insert unnamed chat
INSERT INTO chats (ws_id, type, members)
    VALUES (1, 'single', '{1,2}'),
    (1, 'group', '{1,3,4}');

INSERT INTO messages (chat_id, sender_id, content)
    VALUES (1, 1, 'Hello world!'),
    (1, 2, 'Hello too!'),
    (1, 3, 'Hello everyone!'),
    (1, 4, 'Hello group!'),
    (1, 5, 'Hello everyone!'),
    (1, 1, 'Hello world!'),
    (1, 2, 'Hello too!'),
    (1, 3, 'Hello everyone!'),
    (1, 1, 'Hello world!'),
    (1, 2, 'Hello too!');
