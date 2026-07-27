# Contexto actual — AWS EKS GitOps Platform

Actualizado: 2026-07-21 (`America/Santiago`)

## Objetivo

Desplegar temporalmente la plataforma en la cuenta AWS real, validar EKS, add-ons, IRSA, Argo CD y ALB end-to-end, registrar evidencia profesional y dejar los recursos activos hasta que Emanuel autorice expresamente la destrucción controlada.

## Repositorio

- Ruta: `/home/emanuelgm1998/proyectos/kubernetes-project`
- Remoto: `git@github.com:Emanuelgm1998/kubernetes-project.git`
- Rama: `main`
- Último commit publicado: `5466dcce3015b9ea0a036f25db6fd06f6db24187`
- Licencia: MIT
- Autor: Emanuel González Michea
- LinkedIn: `https://www.linkedin.com/in/emanuel-gonzalez-michea/`

Commits principales publicados:

- `0e1aed0` — hardening de EKS, GitOps y estado remoto.
- `5f8db00` — corrección/pinning de Trivy y evidencia.
- `9b305fb` — resolución de hallazgos Trivy con KMS y networking.
- `388b8b4` — evidencia validada en README.
- `5466dcc` — licencia MIT y perfil del autor.

GitHub Actions de Terraform, manifests y seguridad fueron aprobados. La evidencia está en `docs/evidence/2026-07-21-hardening-publication.md`.

## Cambios locales pendientes (no publicados)

Por instrucción del usuario, estos cambios son únicamente locales: no hacer commit ni push sin una nueva autorización.

- Runbook completo de IAM Identity Center.
- Checklist de despliegue.
- Plantilla de evidencia live.
- Guardia ejecutable que rechaza el usuario IAM permanente.
- Scripts de plan/apply/kubeconfig/bootstrap/ECR/destroy protegidos por SSO.
- Runbook principal e índices actualizados.

Archivos nuevos locales:

- `docs/operations/identity-center-setup.md`
- `docs/operations/deployment-checklist.md`
- `docs/evidence/deployment-template.md`
- `scripts/07-verify-deployment-identity.sh`

Antes de continuar, ejecutar `git status --short` y preservar estos cambios.

## Estado AWS comprobado en solo lectura

- Cuenta objetivo: `747747309806`
- Región: `us-east-1`
- IAM Identity Center: `ACTIVE`
- Instance ARN: `arn:aws:sso:::instance/ssoins-7223b09690b01fbd`
- Identity Store ID: `d-906670dd89`
- Usuarios de Identity Center: ninguno
- Permission Sets: ninguno
- Account Assignments: ninguno
- Roles `AWSReservedSSO`: ninguno
- Perfiles AWS CLI: solo `default`
- Identidad activa actual: usuario IAM permanente `1998AWS`

El usuario IAM permanente está prohibido para desplegar. `scripts/07-verify-deployment-identity.sh` debe rechazarlo.

## Preparación técnica completada

- Terraform `fmt`, `init` y `validate`: aprobados para bootstrap y dev.
- Kustomize: Kubernetes y Argo CD renderizan correctamente.
- Helm: AWS Load Balancer Controller, External Secrets, Argo CD y Metrics Server renderizados.
- ShellCheck y sintaxis Bash: aprobados.
- Gitleaks/escaneo de patrones sensibles: sin secretos.
- Trivy: cero hallazgos HIGH/CRITICAL después del hardening.
- Política IAM del Load Balancer Controller: coincidencia exacta con upstream `v3.4.2`.
- Backend previsto: S3 versionado, KMS CMK, bloqueo público, TLS obligatorio y locking nativo.
- EKS: `1.35`, Access Entry explícito, IRSA, KMS Secrets, IMDSv2 y nodos privados.

No se ha ejecutado ningún `terraform apply` ni se ha creado infraestructura del proyecto.

## Únicos placeholders de configuración

1. ARN real del rol `AWSReservedSSO_PlatformAdministrator_*` en `terraform.tfvars`.
2. Nombre del bucket remoto en `backend.hcl`.
3. ARN KMS del backend en `backend.hcl`.

No inventar ninguno. El ARN se obtiene con `aws iam list-roles`; bucket y KMS se obtienen de los outputs del bootstrap después de su apply autorizado.

## Próximos pasos manuales en AWS Console

Seguir `docs/operations/identity-center-setup.md`:

1. Crear y activar el usuario de IAM Identity Center con los datos reales de Emanuel.
2. Configurar MFA.
3. Crear el Permission Set `PlatformAdministrator` con `AdministratorAccess` y sesión de dos horas.
4. Asignar el usuario y Permission Set a la cuenta `747747309806`.
5. Copiar el AWS access portal URL real desde Identity Center Settings.
6. Ejecutar `aws configure sso` y crear el perfil `kubernetes-project`.

No inventar correo, username, Start URL, User ID ni ARN del rol.

## Frase de autorización para continuar

Cuando IAM Identity Center y el perfil estén listos, Emanuel puede indicar:

> IAM Identity Center y el perfil kubernetes-project están configurados. Te autorizo a crear el backend S3/KMS, desplegar EKS y GitOps, ejecutar las pruebas end-to-end y registrar evidencia. Deja los recursos activos y no ejecutes destroy.

Incluso con esa autorización, trabajar por etapas:

1. Verificar SSO, cuenta, región y ARN real.
2. Plan backend y revisión.
3. Apply backend autorizado.
4. Configurar `backend.hcl` y `terraform.tfvars` ignorados.
5. Plan EKS y revisión.
6. Apply EKS autorizado.
7. Bootstrap GitOps.
8. Evidencia de EKS, add-ons, IRSA, Argo CD, ALB y HTTP 200.
9. Dejar recursos activos.

## Límite de destrucción

No ejecutar `terraform destroy`, eliminaciones AWS ni limpieza Kubernetes hasta que Emanuel diga expresamente:

> Autoriza la destrucción controlada.

Al destruir, seguir `docs/operations/destroy-guide.md`, eliminar primero recursos administrados por Kubernetes y documentar cero recursos huérfanos.
