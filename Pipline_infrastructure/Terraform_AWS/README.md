# AWS Infrastructure with Terraform

تم تحويل جميع البنية التحتية من Azure إلى AWS باستخدام Terraform.

## 📁 البنية

### 1. Terraform_Create_Storage
إنشاء البنية التحتية لتخزين Terraform State:
- **S3 Bucket**: لتخزين ملفات `.tfstate`
- **DynamoDB Table**: لقفل الـ State (State Locking)
- **Versioning**: تمكين النسخ الاحتياطي التلقائي
- **Encryption**: تشفير البيانات
- **Public Access Block**: منع الوصول العام

### 2. Terraform_AIVmServer
إنشاء خادم AI على AWS:
- **VPC & Networking**: VPC, Subnet, Internet Gateway, Route Table
- **Security Group**: SSH (22), HTTP (80), App (8000)
- **EC2 Instance**: t3.xlarge (4 vCPU, 16GB RAM)
- **OS**: Ubuntu 20.04 LTS
- **Storage**: 256GB gp3
- **Elastic IP**: عنوان IP ثابت

### 3. Terraform_BackendVmServer
إنشاء خادم Backend على AWS:
- **VPC & Networking**: VPC, Subnet, Internet Gateway, Route Table
- **Security Group**: SSH (22), HTTP (80), HTTPS (443), App (8000)
- **EC2 Instance**: t3.medium (2 vCPU, 4GB RAM)
- **OS**: Ubuntu 22.04 LTS
- **Storage**: 30GB gp3
- **Elastic IP**: عنوان IP ثابت

## 🚀 الاستخدام

### الخطوة 1: إعداد AWS CLI

تأكد من تكوين AWS CLI:
```powershell
aws configure
```

أو قم بتحديث الملفات `terraform.tfvars` في كل مجلد بالبيانات الخاصة بك.

### الخطوة 2: إنشاء البنية التحتية للتخزين (مرة واحدة فقط)

```powershell
cd Terraform_Create_Storage
terraform init
terraform plan
terraform apply
```

**ملاحظة**: احفظ اسم S3 Bucket و DynamoDB Table وقم بتحديثهم في ملفات `Backend.tf` للمشاريع الأخرى.

### الخطوة 3: نشر خادم AI

```powershell
cd ..\Terraform_AIVmServer
terraform init
terraform plan
terraform apply
```

### الخطوة 4: نشر خادم Backend

```powershell
cd ..\Terraform_BackendVmServer
terraform init
terraform plan
terraform apply
```

## ⚙️ المتغيرات المطلوبة

في كل ملف `terraform.tfvars` يجب تحديث:

### للـ Storage:
- `aws_access_key`: AWS Access Key ID
- `aws_secret_key`: AWS Secret Access Key
- `bucket_name`: اسم فريد للـ S3 Bucket

### للـ AI Server & Backend Server:
- `aws_access_key`: AWS Access Key ID
- `aws_secret_key`: AWS Secret Access Key
- `aws_region`: المنطقة المطلوبة (مثل: us-east-1)
- `ssh_public_key`: مفتاح SSH العام للوصول للخادم

## 📊 المخرجات

### AI Server:
- `public_ip`: عنوان IP العام للخادم
- `instance_id`: معرف EC2 Instance
- `vm_admin_username`: اسم المستخدم (ubuntu)

### Backend Server:
- `public_ip`: عنوان IP العام للخادم
- `instance_id`: معرف EC2 Instance
- `vm_admin_username`: اسم المستخدم (ubuntu)

## 🔐 الأمان

- جميع المتغيرات الحساسة مُعلّمة بـ `sensitive = true`
- Security Groups مُكونة للسماح بالمنافذ الضرورية فقط
- S3 State Bucket مُشفّر ومحمي من الوصول العام
- DynamoDB Table للحماية من التعديلات المتزامنة

## 💰 التكاليف التقديرية

- **t3.xlarge** (AI Server): ~$0.1664/hour (~$120/month)
- **t3.medium** (Backend Server): ~$0.0416/hour (~$30/month)
- **S3 Storage**: ~$0.023/GB/month
- **EIP**: مجاني أثناء الاستخدام، $0.005/hour في حالة عدم الربط

## 🗑️ حذف الموارد

لحذف جميع الموارد وتجنب التكاليف:

```powershell
# حذف Backend Server
cd Terraform_BackendVmServer
terraform destroy

# حذف AI Server
cd ..\Terraform_AIVmServer
terraform destroy

# حذف Storage (اختياري - إذا لم تعد بحاجة للـ State)
cd ..\Terraform_Create_Storage
terraform destroy
```

## 📝 ملاحظات

1. **اسم S3 Bucket** يجب أن يكون فريداً عالمياً
2. بعد إنشاء Storage، قم بتحديث `Backend.tf` في المشاريع الأخرى باسم الـ Bucket الفعلي
3. يمكنك استخدام **AWS IAM Roles** بدلاً من Access Keys للأمان الأفضل
4. تأكد من إيقاف الـ Instances عند عدم الحاجة لتوفير التكاليف

## 🔄 التحديث من Azure إلى AWS

تم التحويل من:
- Azure Resource Groups → AWS VPC
- Azure VNet → AWS VPC
- Azure NSG → AWS Security Groups
- Azure Public IP → AWS Elastic IP
- Azure VM → AWS EC2
- Azure Storage Account → AWS S3
- Standard_D4s_v3 → t3.xlarge
- Standard_B2als_v2 → t3.medium
