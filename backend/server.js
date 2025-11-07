require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');
const AWS = require('aws-sdk');
const authRoutes = require('./routes/auth');
const expenseRoutes = require('./routes/expenses');
const employeeRoutes = require('./routes/employees');
const adminRoutes = require('./routes/admin');
const allowanceRoutes = require('./routes/allowance');

const auth = require('./middleware/auth');
const fs = require('fs');

const app = express();

// Remove or restrict debug logs in production
function devLog(...args) {
  if (process.env.NODE_ENV !== 'production') {
    console.log(...args);
  }
}

// Use only the cors package, with correct config
app.use(cors({
  origin: [process.env.FRONTEND_URL, process.env.FRONTEND_URL_SECONDARY],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-jwt-token'],
  exposedHeaders: ['Content-Range', 'X-Content-Range']
}));

// Ensure CORS preflight requests are handled for all routes
app.options('*', cors({
  origin: [process.env.FRONTEND_URL, process.env.FRONTEND_URL_SECONDARY ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-jwt-token'],
  exposedHeaders: ['Content-Range', 'X-Content-Range']
}));

app.use(express.json());

// Database connection
const db = mysql.createConnection({
  host: process.env.DB_HOST ,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD ,
  database: process.env.DB_NAME
});

db.connect((err) => {
  if (err) {
    console.error('Error connecting to database:', err);
    return;
  }
  devLog('Connected to MySQL database');
});

// AWS S3 configuration
AWS.config.update({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION
});
const s3 = new AWS.S3();
const S3_BUCKET = process.env.AWS_S3_BUCKET;

const upload = multer({
  storage: multer.memoryStorage()
});

// S3 upload helper
function uploadToS3(file, folder) {
  const params = {
    Bucket: S3_BUCKET, // Uses env variable for bucket name
    Key: `${folder}/${Date.now()}_${file.originalname}`,
    Body: file.buffer,
    ContentType: file.mimetype
  };
  return s3.upload(params).promise();
}

// Serve uploaded files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Health check route for root
app.get('/', (req, res) => {
  res.send('API is running');
});

// Register route handlers
app.use('/api/auth', authRoutes);
app.use('/api/expenses', expenseRoutes);
app.use('/api/employees', employeeRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/allowance-rates', allowanceRoutes);

// Search projects
app.get('/api/expenses/projects/search', auth, (req, res) => {
  const query = req.query.query;
  const searchQuery = `
    SELECT * FROM projects WHERE project_code LIKE ? OR project_name LIKE ?`;
  db.query(searchQuery, [`%${query}%`, `%${query}%`], (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: 'Database error' });
    }
    res.json(results);
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  if (process.env.NODE_ENV !== 'production') {
    console.error(err.stack);
  }
  res.status(500).json({ message: 'Something broke!' });
});

// Start server
const PORT = process.env.PORT || 8000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});