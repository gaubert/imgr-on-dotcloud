<!doctype html>
<title>Hello from Flask</title>
{% if name %}
  <h1>Hello {{ name }}. Welcome to Zoobert land !</h1>
{% else %}
  <h1>Hello World pretty. Welcome to Zoobert land !</h1>
{% endif %}

