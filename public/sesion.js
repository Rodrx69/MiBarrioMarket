// Obtener el boton de cerrar sesion
const botonCerrarSesion =
    document.getElementById("btn-cerrar-sesion");
// Detectar cuando el usuario desea cerrar sesion
if (botonCerrarSesion) {
    botonCerrarSesion.addEventListener("click", async function() {
        botonCerrarSesion.disabled = true;
        botonCerrarSesion.textContent = "Cerrando sesion...";
        try {
            // Solicitar al servidor el cierre de sesion
            const respuesta = await fetch("/api/logout", {
                method: "POST",
                credentials: "same-origin"
            });
            const resultado = await respuesta.json();
            if (!respuesta.ok || !resultado.correcto) {
                throw new Error(
                    resultado.mensaje ||
                    "No se pudo cerrar la sesion."
                );
            }
            // Regresar al inicio de sesion
            window.location.replace("/");
        } catch (error) {
            console.error(
                "Error al cerrar sesion:",
                error
            );
            alert(
                "No se pudo cerrar la sesion. Intenta nuevamente."
            );
            botonCerrarSesion.disabled = false;
            botonCerrarSesion.textContent = "Cerrar sesión";
        }
    });
}