require('dotenv').config();

const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

const app = express();
app.use(cors());
app.use(express.json());

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

const verificarToken = (req, res, next) => {
  const authHeader = req.header('Authorization');
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Acceso denegado o formato inválido. Usa: Bearer <token>' });
  }

  try {
    const token = authHeader.split(' ')[1];
    const verificado = jwt.verify(token, process.env.JWT_SECRET);
    req.usuario = verificado; 
    next(); 
  } catch (error) {
    res.status(401).json({ error: 'Token inválido o expirado.' });
  }
};

app.post('/api/auth/registro', async (req, res) => {
  const { correo, password } = req.body;
  
  if (!correo || !password) {
    return res.status(400).json({ error: 'Correo y contraseña obligatorios.' });
  }

  try {
    const salt = await bcrypt.genSalt(10);
    const passwordEncriptada = await bcrypt.hash(password, salt);

    await pool.query(
      'INSERT INTO public.usuarios (correo, password) VALUES ($1, $2)',
      [correo, passwordEncriptada]
    );

    res.status(201).json({ mensaje: 'Usuario registrado.' });
  } catch (error) {
    res.status(500).json({ error: 'Error al registrar.' });
  }
});

app.post('/api/auth/login', async (req, res) => {
  const { correo, password } = req.body;

  if (!correo || !password) {
    return res.status(400).json({ error: 'Campos incompletos.' });
  }

  try {
    const userResult = await pool.query('SELECT * FROM public.usuarios WHERE correo = $1', [correo]);
    if (userResult.rows.length === 0) {
      return res.status(400).json({ error: 'Credenciales inválidas.' });
    }

    const usuario = userResult.rows[0];
    const passwordValida = await bcrypt.compare(password, usuario.password);
    
    if (!passwordValida) {
      return res.status(400).json({ error: 'Credenciales inválidas.' });
    }

    const token = jwt.sign(
      { id_usuario: usuario.id_usuario },
      process.env.JWT_SECRET,
      { expiresIn: '2h' } 
    );

    res.json({ mensaje: 'Login exitoso', token: token });

  } catch (error) {
    res.status(500).json({ error: 'Error en Login.' });
  }
});

app.get('/api/pronosticos', verificarToken, async (req, res) => {
  try {
    const resultado = await pool.query('SELECT * FROM public.pronostico ORDER BY id_pronostico ASC');
    res.json(resultado.rows);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener pronósticos.' });
  }
});

app.post('/api/pronosticos', verificarToken, async (req, res) => {
  const { idPartido, golesE1, golesE2 } = req.body;
  
  try {
    const maxIdResult = await pool.query('SELECT MAX(id_pronostico) FROM public.pronostico');
    const siguienteId = (maxIdResult.rows[0].max || 0) + 1;
    const idUsuarioReal = req.usuario.id_usuario;

    await pool.query(
      'INSERT INTO public.pronostico (id_pronostico, id_partido, goles_e1, goles_e2, id_usuario) VALUES ($1, $2, $3, $4, $5)',
      [siguienteId, idPartido, golesE1, golesE2, idUsuarioReal]
    );

    res.status(201).json({ mensaje: 'Pronóstico guardado.' });
  } catch (error) {
    res.status(500).json({ error: 'Error al registrar el pronóstico.' });
  }
});

const puerto = process.env.PORT || 3017;
app.listen(puerto, () => {
  console.log(`SERVIDOR CORRIENDO EN PUERTO: ${puerto}`);
});