# Zum-Bee · App móvil

App Android del sistema **Zum-Bee**: monitoreo IoT no invasivo de colmenas.
Muestra en vivo la temperatura, la humedad, el peso y el sonido de la colmena,
avisa con notificaciones y permite calentar o enfriar la colmena desde el celular.

Proyecto del curso *IoT: Fundamentos y Aplicaciones*, Pontificia Universidad Javeriana (2026).
Equipo: Daniel Santiago Bernal Prieto, Julián Andrés Venegas Susa y Jaime Hernando Avendaño López.

---

## Qué hace la app

- **Cuenta de usuario:** registro, inicio de sesión y cambio de contraseña por correo desde Perfil (Firebase Authentication).
- **Apiario:** crear, editar y borrar colmenas. Cada colmena tiene un canal de ThingSpeak y un identificador de nodo.
- **Inicio:**
  - Medidores de temperatura, peso y humedad (se actualizan cada 20 s).
  - Tarjeta **"Estado de la colmena"**:
    - Semáforo (verde, amarillo, rojo o gris) y sus motivos.
    - Estado estimado por el sonido (sana, sin reina, riesgo de varroa preliminar, pre-enjambre) con sus porcentajes.
    - Temperatura y humedad de afuera, zumbido (Hz y dB) y estado del actuador.
  - Botones **Calentar** y **Enfriar**: activan el calefactor o el ventilador por 20 minutos.
- **Historial:** gráficas de temperatura, humedad y peso desde ThingSpeak.
- **Alertas:** reglas de temperatura, humedad, peso y nodo sin datos, más los **avisos del nodo** que manda la Raspberry.
- **Perfil:** editar datos, cambiar contraseña e interruptor **"Recibir alertas"** para las notificaciones push.

> El estado por sonido es una **estimación**: viene de un modelo entrenado con datos sintéticos
> basados en estudios publicados. No reemplaza la revisión de la colmena.

---

## Cómo se conecta con el resto del sistema

```
Sensores → ESP32 → (Wi-Fi, MQTT) → Raspberry Pi 3 → ThingSpeak  → App (gráficas)
                                                  → Firebase    → App (estado, alertas, push)
App → Firebase (orden) → Raspberry → MQTT → ESP32 → calefactor / ventilador
```

| La app lee o escribe | Dónde |
|---|---|
| Últimas lecturas e historial | ThingSpeak, canal público (`channels/<canal>/feeds.json`) |
| Estado en vivo y analítica | Firestore `nodes/<nodo>` → `ultimo`, `analitica`, `estado`, `conexion` |
| Avisos del nodo | Firestore `nodes/<nodo>/alertas` |
| Órdenes (calentar / enfriar) | Firestore `nodes/<nodo>.comando` (las escribe la app) |
| Usuarios y colmenas | Firestore `users/<uid>` y `users/<uid>/hives` |
| Notificaciones push | Firebase Cloud Messaging, tema `zumbee_<nodo>` (ej. `zumbee_ZB_01`) |

---

## Instalar la app en un celular (solo usarla)

1. Pide el archivo **`app-release.apk`** al equipo (o genéralo con la sección "Generar el APK").
2. Pásalo al celular Android y ábrelo.
3. Si Android lo pide, permite "Instalar apps de origen desconocido".
4. Abre **Zum-Bee**, crea una cuenta y acepta el permiso de **notificaciones**.
5. Sigue la sección **"Configurar la colmena en la app"**.

---

## Instalar el proyecto para desarrollo

### 1. Lo que necesitas

- **Flutter** (versión estable reciente; probado con Flutter 3.50) → https://docs.flutter.dev/get-started/install
- **Android Studio** con el Android SDK (para compilar y para el emulador).
- **VS Code** con las extensiones *Flutter* y *Dart* (opcional, pero recomendado).
- Un **celular Android** con "Depuración USB" activada, o un emulador.
- Acceso al proyecto de **Firebase** del equipo.

Para revisar que todo esté bien instalado:

```bash
flutter doctor
```

### 2. Descargar el código

```bash
git clone https://github.com/DanyBer/zumbee-app.git
cd zumbee-app
flutter pub get
```

### 3. Firebase

El proyecto ya trae la configuración de Firebase:
- `android/app/google-services.json`
- `lib/firebase_options.dart`

En la consola de Firebase deben estar activos:

1. **Authentication** → método *Correo electrónico/contraseña*.
2. **Firestore Database** con estas reglas (pestaña *Reglas* → *Publicar*):

   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /nodes/{nodeId} {
         allow read, write: if request.auth != null;
         match /alertas/{alertaId} {
           allow read: if request.auth != null;
         }
       }
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
         match /hives/{hiveId} {
           allow read, write: if request.auth != null && request.auth.uid == userId;
         }
       }
     }
   }
   ```

3. **Cloud Messaging** → *Configuración del proyecto* → pestaña *Cloud Messaging* →
   "API de Firebase Cloud Messaging (V1)" **habilitada**.

> La llave de servicio de la Raspberry (`firebase-clave.json`) **nunca** se sube a este repositorio.

### 4. Correr la app

Con el celular conectado por USB (o el emulador abierto):

```bash
flutter run
```

Para revisar el código sin correrlo:

```bash
flutter analyze
```

### 5. Generar el APK

```bash
flutter build apk --release
```

El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`.

---

## Configurar la colmena en la app

1. Entra a **Apiario** → **+** (nueva colmena) o edita una existente.
2. Llena:
   - **Canal de ThingSpeak:** `3533092`
   - **Identificador del nodo:** `ZB_01` (igual que en el ESP32 y la Raspberry)
3. Guarda. En **Inicio** deben aparecer los medidores y la tarjeta "Estado de la colmena".
4. En **Perfil**, deja prendido **"Recibir alertas"**.

El canal de ThingSpeak debe ser **público**, porque la app lo lee sin clave.

---

## Estructura del código

```
lib/
├── main.dart                    Arranque, Firebase y pantalla de inicio de sesión
├── firebase_options.dart        Configuración de Firebase (generada)
├── core/
│   ├── app_state.dart           Colmena seleccionada, canal y nodo
│   ├── mycolors.dart            Colores de la app
│   └── mytextstyles.dart        Estilos de texto
├── components/
│   ├── analytics_card.dart      Tarjeta "Estado de la colmena"
│   ├── metric_gauge.dart        Medidores circulares
│   ├── history_chart.dart       Gráficas del historial
│   ├── alert_card.dart          Tarjeta de alerta
│   ├── hive.dart                Tarjeta de colmena
│   └── zumbee_app_bar.dart      Barra superior
├── services/
│   ├── auth_service.dart        Inicio de sesión y contraseña
│   ├── database_service.dart    Usuarios y colmenas (Firestore)
│   ├── node_service.dart        Documento del nodo, avisos y órdenes
│   ├── push_service.dart        Notificaciones push (FCM)
│   ├── thingspeak_service.dart  Lecturas de ThingSpeak
│   └── alert_service.dart       Reglas de alerta en la app
└── screens/                     Pantallas: bienvenida, login, registro, inicio,
                                 historial, alertas, apiario, colmena y perfil
```

---

## Problemas comunes

| Problema | Qué hacer |
|---|---|
| "Esta colmena no tiene nodo" | Pon el canal de ThingSpeak en la colmena (Apiario → editar). |
| No aparece la tarjeta "Estado de la colmena" | Pon el identificador del nodo `ZB_01` en la colmena. |
| La tarjeta dice "Sin datos" | La Raspberry no está escribiendo en Firebase: revisa `journalctl -u zumbee -f`. |
| Los botones dicen "No se pudo enviar la orden" | Revisa internet y las reglas de Firestore (`nodes/{nodeId}`). |
| No llegan notificaciones | Permiso de notificaciones en Android, "Recibir alertas" prendido y Cloud Messaging V1 habilitado. |
| Error al compilar después de actualizar Flutter | `flutter clean` y luego `flutter pub get`. |
