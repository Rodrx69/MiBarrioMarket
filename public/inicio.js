// Obtener los elementos del formulario
const formularioAcceso =
    document.getElementById("formulario-acceso");
const campoUsuario =
    document.getElementById("nombre-usuario");
const campoContrasena =
    document.getElementById("contrasena");
const mensajeUsuario =
    document.getElementById("mensaje");
const botonIngreso =
    formularioAcceso.querySelector('button[type="submit"]');
// Detectar el envío del formulario
formularioAcceso.addEventListener("submit", async function(evento) {
    evento.preventDefault();
    const usuario = campoUsuario.value.trim();
    const contrasena = campoContrasena.value;
    if (!usuario || !contrasena) {
        mensajeUsuario.textContent =
            "Ingresa tu usuario y contraseña.";
        return;
    }
    botonIngreso.disabled = true;
    mensajeUsuario.textContent =
        "Verificando credenciales...";
    try {
        const respuesta = await fetch("/api/login", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            credentials: "same-origin",
            body: JSON.stringify({
                usuario: usuario,
                contrasena: contrasena
            })
        });
        const resultado = await respuesta.json();
        if (!respuesta.ok || !resultado.correcto) {
            throw new Error(
                resultado.mensaje ||
                "Usuario o contraseña incorrectos."
            );
        }
        // Determinar el destino según el rol autorizado
        const destinos = {
            CAJERO: "/ventas.html",
            REPONEDOR: "/compras.html"
        };
        const destino = destinos[resultado.rol];
        if (!destino) {
            throw new Error(
                "El usuario no tiene un rol autorizado."
            );
        }
        mensajeUsuario.textContent =
            "Acceso correcto. Bienvenido.";
        window.location.assign(destino);
    } catch (error) {
        console.error("Error al iniciar sesión:", error);
        mensajeUsuario.textContent =
            error.message ||
            "No se pudo conectar con el servidor.";
        campoContrasena.value = "";
    } finally {
        botonIngreso.disabled = false;
    }
});