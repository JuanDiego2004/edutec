
/* ========= DATOS ========= */
let estudiantes = JSON.parse(localStorage.getItem("estudiantes")) || [];
let calificaciones = JSON.parse(localStorage.getItem("calificaciones")) || {};
let asistencia = JSON.parse(localStorage.getItem("asistencia")) || [];

/* ==========================================================
    DOMContentLoaded UNIFICADO
========================================================== */
document.addEventListener("DOMContentLoaded", () => {
    if (document.getElementById("listaEstudiantes")) mostrarLista();
    if (document.getElementById("selectEstudiante")) cargarSelectCalificaciones();
    if (document.getElementById("selBoleta")) cargarSelectBoleta();
    if (document.getElementById("selEst")) cargarSelectAsistencia();
    if (document.getElementById("tablaAsistencia")) mostrarAsistencia();
});


/* ==========================================================
    REGISTRO
========================================================== */
function registrar(e) {
    e.preventDefault();

    const nombre = document.getElementById("nombreEst").value;
    const grado = document.getElementById("gradoEst").value;
    const seccion = document.getElementById("seccionEst").value.toUpperCase();

    const id = Date.now();

    estudiantes.push({ id, nombre, grado, seccion });
    localStorage.setItem("estudiantes", JSON.stringify(estudiantes));

    // Crear espacio para notas
    calificaciones[id] = {};
    localStorage.setItem("calificaciones", JSON.stringify(calificaciones));

    mostrarLista();
    cargarSelectCalificaciones();
    cargarSelectBoleta();
    cargarSelectAsistencia();

    document.getElementById("formRegistro").reset();
    alert("Estudiante registrado con éxito");
}

function mostrarLista() {
    const lista = document.getElementById("listaEstudiantes");
    if (!lista) return;

    lista.innerHTML = estudiantes
        .map(e => `<div class="estudiante">${e.nombre} - ${e.grado} (${e.seccion})</div>`)
        .join("");
}


/* ==========================================================
    CALIFICACIONES
========================================================== */
function cargarSelectCalificaciones() {
    const select = document.getElementById("selectEstudiante");
    if (!select) return;

    select.innerHTML = `<option value="">Seleccione...</option>` +
        estudiantes.map(e => `<option value="${e.id}">${e.nombre}</option>`).join("");
}


function guardarNotas() {
    const id = document.getElementById("selectEstudiante").value;
    if (!id) return alert("Seleccione un estudiante");

    const datos = {
        mate: document.getElementById("mate").value,
        comu: document.getElementById("comu").value,
        ciencia: document.getElementById("ciencia").value,
        personal: document.getElementById("personal")?.value || 0,
        religion: document.getElementById("religion")?.value || 0,
        ingles: document.getElementById("ingles")?.value || 0,
    };

    calificaciones[id] = datos;
    localStorage.setItem("calificaciones", JSON.stringify(calificaciones));

    document.getElementById("resultado").innerHTML = "<b>Notas guardadas ✔</b>";
}


/* ==========================================================
    BOLETA
========================================================== */

function cargarSelectBoleta() {
    const sel = document.getElementById("selBoleta");
    if (!sel) return;

    sel.innerHTML = `<option value="">Seleccione...</option>` +
        estudiantes.map(e => `<option value="${e.id}">${e.nombre}</option>`).join("");
}

function generarBoleta() {
    const id = document.getElementById("selBoleta").value;
    const area = document.getElementById("boletaArea");

    if (!id) {
        area.innerHTML = "";
        return;
    }

    const est = estudiantes.find(e => e.id == id);
    const notas = calificaciones[id] || {};

    const cursos = [
        { nombre: "Matemática", key: "mate" },
        { nombre: "Comunicación", key: "comu" },
        { nombre: "Ciencia y Tecnología", key: "ciencia" },
        { nombre: "Desarrollo Personal", key: "personal" },
        { nombre: "Religión", key: "religion" },
        { nombre: "Inglés", key: "ingles" }
    ];

    let total = 0, cantidad = 0;

    let filas = cursos.map(c => {
        const nota = parseFloat(notas[c.key]) || 0;
        total += nota; cantidad++;

        return `<tr><td>${c.nombre}</td><td>${nota}</td></tr>`;
    }).join("");

    const promedio = (total / cantidad).toFixed(1);

    area.innerHTML = `
        <h3>Boleta de Notas</h3>
        <p><b>Nombre:</b> ${est.nombre}</p>
        <p><b>Grado:</b> ${est.grado}</p>
        <p><b>Sección:</b> ${est.seccion}</p>

        <table border="1" width="100%" style="margin-top:15px;">
            <thead>
                <tr><th>Curso</th><th>Nota</th></tr>
            </thead>
            <tbody>
                ${filas}
                <tr><th>Promedio General</th><th>${promedio}</th></tr>
            </tbody>
        </table>
    `;
}


/* ==========================================================
    ASISTENCIA
========================================================== */

function cargarSelectAsistencia() {
    const sel = document.getElementById("selEst");
    if (!sel) return;

    sel.innerHTML = `<option value="">Seleccione...</option>` +
        estudiantes.map(e => `<option value="${e.id}">${e.nombre}</option>`).join("");
}

function marcarAsistencia() {
    const id = document.getElementById("selEst").value;
    const estado = document.getElementById("estado").value;

    if (!id) return alert("Seleccione un estudiante");

    const est = estudiantes.find(e => e.id == id);

    asistencia.push({
        nombre: est.nombre,
        fecha: new Date().toLocaleDateString(),
        estado
    });

    localStorage.setItem("asistencia", JSON.stringify(asistencia));
    mostrarAsistencia();
}

function mostrarAsistencia() {
    const tabla = document.getElementById("tablaAsistencia");
    if (!tabla) return;

    tabla.innerHTML = asistencia
        .map(a => `
            <tr>
                <td>${a.nombre}</td>
                <td>${a.fecha}</td>
                <td>${a.estado}</td>
            </tr>
        `)
        .join("");
}
