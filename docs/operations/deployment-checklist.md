# Deployment Checklist

□ Crear Permission Set
□ Asignar usuario
□ Ejecutar aws configure sso
□ aws sso login
□ aws sts get-caller-identity
□ Crear backend S3/KMS
□ Configurar backend.hcl
□ Configurar terraform.tfvars
□ terraform plan backend
□ Aprobación
□ terraform apply backend
□ terraform plan EKS
□ Aprobación
□ terraform apply EKS
□ Bootstrap GitOps
□ Validaciones Kubernetes
□ Evidencia
□ Destrucción controlada
