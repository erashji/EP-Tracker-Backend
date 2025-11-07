const corsMiddleware = (req, res, next) => {
  // Use environment variable for allowed origin
  const allowedOrigin = process.env.FRONTEND_URL || '';
  res.header('Access-Control-Allow-Origin', allowedOrigin);
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, x-jwt-token');
  res.header('Access-Control-Allow-Credentials', true);

  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
};

module.exports = corsMiddleware;
