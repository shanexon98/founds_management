# Management Funds

Aplicación Flutter para la gestión y suscripción a fondos, con integración opcional a AWS SNS para notificaciones por email y SMS. Este documento describe cómo preparar el entorno, configurar credenciales de forma segura y ejecutar el proyecto en desarrollo y producción.

## Requisitos
- Flutter SDK (3.x) y Dart (SDK `>=3.10.8`)
- Xcode 15+ (macOS) para iOS; Android Studio para Android
- Dispositivo/emulador iOS 13+ o Android
- Cuenta AWS (opcional, solo si usarás notificaciones)

## Instalación
- Clonar el repositorio
- Instalar dependencias



```bash
flutter pub get
flutter analyze
```

<img width="1170" height="2532" alt="Simulator Screenshot - iPhone 16e - 2026-03-19 at 23 04 25" src="https://github.com/user-attachments/assets/7e025a50-f37f-40d9-90ae-fe1c90e0d5a2" />


## Configuración de credenciales (seguro)
Las credenciales **NO** se guardan en el código. Se leen mediante `dart-define` en tiempo de ejecución. Los nombres de variables:
- `AWS_REGION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN` (opcional)
- `SNS_TOPIC_ARN` (opcional)

El código las consume desde [env.dart](file:///Users/shanexonortiz/Documents/Proyectos/Flutter/management_funds/lib/core/config/env.dart) usando `String.fromEnvironment`.

### Opción A: pasar credenciales con dart-define

```bash
flutter run \
  --dart-define=AWS_REGION=us-east-1 \
  --dart-define=AWS_ACCESS_KEY_ID=XXXX \
  --dart-define=AWS_SECRET_ACCESS_KEY=YYYY \
  --dart-define=AWS_SESSION_TOKEN= \
  --dart-define=SNS_TOPIC_ARN=arn:aws:sns:us-east-1:XXXXXXXXXXXX:mi-topico
```

### Opción B: archivo `.env` local (no subir)
1) Crear `.env` (agregar a `.gitignore`) con contenido:
```
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=XXXX
AWS_SECRET_ACCESS_KEY=YYYY
AWS_SESSION_TOKEN=
SNS_TOPIC_ARN=arn:aws:sns:us-east-1:XXXXXXXXXXXX:mi-topico
```
2) Exportar y ejecutar:
```bash
export $(grep -v '^#' .env | xargs)
flutter run \
  --dart-define=AWS_REGION=$AWS_REGION \
  --dart-define=AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  --dart-define=AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  --dart-define=AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
  --dart-define=SNS_TOPIC_ARN=$SNS_TOPIC_ARN
```

## Ejecución en desarrollo
### iOS
```bash
flutter run -d ios \
  --dart-define=AWS_REGION=us-east-1 \
  --dart-define=AWS_ACCESS_KEY_ID=XXXX \
  --dart-define=AWS_SECRET_ACCESS_KEY=YYYY \
  --dart-define=SNS_TOPIC_ARN=arn:aws:sns:us-east-1:XXXXXXXXXXXX:mi-topico
```

### Android
```bash
flutter run -d android \
  --dart-define=AWS_REGION=us-east-1 \
  --dart-define=AWS_ACCESS_KEY_ID=XXXX \
  --dart-define=AWS_SECRET_ACCESS_KEY=YYYY \
  --dart-define=SNS_TOPIC_ARN=arn:aws:sns:us-east-1:XXXXXXXXXXXX:mi-topico
```

## Builds
### APK
```bash
flutter build apk \
  --release \
  --dart-define=AWS_REGION=us-east-1 \
  --dart-define=AWS_ACCESS_KEY_ID=XXXX \
  --dart-define=AWS_SECRET_ACCESS_KEY=YYYY \
  --dart-define=SNS_TOPIC_ARN=arn:aws:sns:us-east-1:XXXXXXXXXXXX:mi-topico
```

### iOS (Runner)
```bash
flutter build ios \
  --release \
  --dart-define=AWS_REGION=us-east-1 \
  --dart-define=AWS_ACCESS_KEY_ID=XXXX \
  --dart-define=AWS_SECRET_ACCESS_KEY=YYYY \
  --dart-define=SNS_TOPIC_ARN=arn:aws:sns:us-east-1:XXXXXXXXXXXX:mi-topico
```
Luego abrir `Runner.xcworkspace` en Xcode para firmar y distribuir.

## Estructura relevante
- UI y páginas:
  - [FundsHomePage](file:///Users/shanexonortiz/Documents/Proyectos/Flutter/management_funds/lib/features/funds/presentation/pages/funds_home_page.dart)
  - [FundsPage](file:///Users/shanexonortiz/Documents/Proyectos/Flutter/management_funds/lib/features/funds/presentation/pages/funds_page.dart)
  - [MyFundsPage](file:///Users/shanexonortiz/Documents/Proyectos/Flutter/management_funds/lib/features/funds/presentation/pages/my_funds_page.dart)
  - [TransactionsPage](file:///Users/shanexonortiz/Documents/Proyectos/Flutter/management_funds/lib/features/funds/presentation/pages/transactions_page.dart)
- Cubit/Estado:
  - [FundsCubit](file:///Users/shanexonortiz/Documents/Proyectos/Flutter/management_funds/lib/features/funds/presentation/cubit/funds_cubit.dart)
  - [FundsState](file:///Users/shanexonortiz/Documents/Proyectos/Flutter/management_funds/lib/features/funds/presentation/cubit/funds_state.dart)
- Servicios:
  - [AwsNotificationService](file:///Users/shanexonortiz/Documents/Proyectos/Flutter/management_funds/lib/core/services/aws_notification_service.dart)
  - [AwsSigV4](file:///Users/shanexonortiz/Documents/Proyectos/Flutter/management_funds/lib/core/services/aws_signer.dart)
- Tema y UI:
  - [AppTheme](file:///Users/shanexonortiz/Documents/Proyectos/Flutter/management_funds/lib/core/ui/theme.dart)
  - [BankBackground](file:///Users/shanexonortiz/Documents/Proyectos/Flutter/management_funds/lib/core/ui/background.dart)
  - [BalanceHeader](file:///Users/shanexonortiz/Documents/Proyectos/Flutter/management_funds/lib/features/funds/presentation/widgets/balance_header.dart)

## Comandos útiles
```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```
 
