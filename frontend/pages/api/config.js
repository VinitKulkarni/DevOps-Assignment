export default function handler(req, res) {
  res.status(200).json({ apiUrl: process.env.NEXT_PUBLIC_API_URL });
}
