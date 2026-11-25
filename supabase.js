// Cliente Supabase compartido por index.html y admin.html
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm";

const SUPABASE_URL = "https://dneuijjwgigcoldrmrul.supabase.co";
// Clave publicable (segura en el navegador; el acceso lo controlan las políticas RLS)
const SUPABASE_KEY = "sb_publishable_hqoiT71081Wm2vh6QDCI8Q_q5LQMzSC";

export const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);
