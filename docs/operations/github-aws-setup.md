# Configuración de GitHub y AWS CLI

Esta guía prepara Linux Mint/Ubuntu para sincronizar el repositorio de Kubernetes con GitHub y utilizar AWS CLI de forma segura.

> **Importante:** nunca pegues claves de AWS, tokens de GitHub o credenciales dentro del repositorio, en commits o en conversaciones.

## 1. Instalar GitHub CLI

```bash
sudo apt update
sudo apt install gh
gh --version
```

## 2. Autenticar GitHub

Ejecuta:

```bash
gh auth login
```

Selecciona las siguientes opciones:

1. `GitHub.com`.
2. `SSH`.
3. Crear o utilizar una clave SSH.
4. `Login with a web browser`.
5. Copiar el código mostrado y autorizar GitHub CLI en el navegador.

Comprueba la sesión y la conexión SSH:

```bash
gh auth status
ssh -T git@github.com
```

El remoto esperado para este proyecto es:

```text
git@github.com:Emanuelgm1998/kubernetes-project.git
```

## 3. Instalar AWS CLI v2

Comprueba primero si ya está instalado:

```bash
aws --version
```

Para un equipo Linux `x86_64`:

```bash
sudo apt install curl unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install
aws --version
```

Para ARM64 se debe utilizar `awscli-exe-linux-aarch64.zip` en lugar del instalador `x86_64`.

## 4. Configurar credenciales AWS

### Método recomendado: IAM Identity Center/SSO

```bash
aws configure sso
```

Configura:

- Nombre de sesión SSO.
- URL del portal SSO.
- Región de SSO.
- Cuenta y rol autorizados.
- Región predeterminada: `us-east-1`.
- Formato de salida: `json`.
- Nombre del perfil: `kubernetes-project`.

Inicia sesión y valida la identidad:

```bash
aws sso login --profile kubernetes-project
aws sts get-caller-identity --profile kubernetes-project
```

### Access keys permanentes

No se recomiendan para este proyecto y están prohibidas para GitHub Actions. Si una organización exige credenciales temporales mediante otro mecanismo, debe documentar su origen, duración, alcance, rotación y proceso de revocación fuera del repositorio.

## 5. Activar el perfil para Terraform

En cada terminal donde se trabaje con el proyecto:

```bash
export AWS_PROFILE=kubernetes-project
export AWS_REGION=us-east-1
```

Valida la configuración:

```bash
aws sts get-caller-identity
aws configure list
```

No ejecutes `terraform apply` hasta revisar primero el plan.

## 6. Entrar al proyecto

```bash
cd /home/emanuelgm1998/proyectos/kubernetes-project
git remote -v
git status -sb
```

## 7. Confirmar antes de publicar

Los dos comandos siguientes deben terminar correctamente:

```bash
gh auth status
aws sts get-caller-identity --profile kubernetes-project
```

Cuando estén listos, solicita continuar con el push. Antes de publicar se debe:

1. Revisar los cambios y descartar artefactos locales como `tfplan`.
2. Verificar que no existan secretos.
3. Crear una rama de trabajo.
4. Ejecutar las validaciones disponibles.
5. Crear un commit, subir la rama y abrir un pull request.

## Documentación oficial

- [Autenticación con GitHub CLI](https://cli.github.com/manual/gh_auth_login)
- [Instalación de AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Configuración y credenciales de AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
