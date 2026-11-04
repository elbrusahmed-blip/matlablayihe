# MATLAB R2024a ↔ GitHub: qoşulma təlimatı

GitHub repozitoriyası: https://github.com/elbrusahmed-blip/matlablayihe

## 1. MATLAB proqramında qoşulmaq

MATLAB-da **Command Window** açın və aşağıdakı iki əmri icra edin:

```matlab
repo = gitclone("https://github.com/elbrusahmed-blip/matlablayihe.git");
cd(repo.WorkingFolder);
```

`gitclone` R2023b-dən mövcuddur, buna görə MATLAB R2024a ilə uyğundur.

**Qeyd:** MATLAB-ın cari qovluğunda artıq `matlablayihe` adlı qovluq varsa, klonlamadan əvvəl başqa qovluğa keçin. Eyni qovluğa iki dəfə klonlamayın.

## 2. Uğurlu olduğunu yoxlamaq

```matlab
repo = gitrepo;
disp(repo.WorkingFolder)
disp(repo.CurrentBranch)
run("baslangic.m");
```

`main` filialını və sinus qrafikini görməlisiniz.

## 3. Yeni layihə fayllarını əlavə etmək

Kodları **Current Folder → matlablayihe** qovluğunun daxilində saxlayın.

```matlab
repo = gitrepo;
add(repo,".");
commit(repo,Message="Add my MATLAB project");
push(repo);
```

`push` üçün GitHub autentifikasiyası tələb oluna bilər. **Personal Access Token (PAT)** yaradıb GitHub-un tələb etdiyi təhlükəsiz autentifikasiya sahəsində istifadə edin. PAT-ni `.m` faylının içinə yazmayın.

MATLAB R2024a-nın Git əmrlərinə alternativ olaraq **Current Folder** → **Source Control** menyusundan dəyişikliklərin qeydiyyata alınması (commit) və göndərilməsi (push) əməliyyatları da istifadə edilə bilər.

## 4. Dəyişiklikləri yükləmək

```matlab
repo = gitrepo;
pull(repo);
```

## 5. Tez rast gəlinən xətalar

- **Destination already exists:** Cari qovluqda `matlablayihe` adlı qovluq var; onu silmədən əvvəl mövcud layihə fayllarınızı yoxlayın və başqa qovluğa keçin.
- **Authentication failed / 403:** GitHub hesabı və PAT icazələrini yoxlayın. Fine-grained token üçün bu repozitoriyada Contents → Read and write tələb olunur.
- **Commit identity missing:** Git-də istifadəçi adı və e-poçt konfiqurasiyası lazım ola bilər; bunları öz məlumatlarınıza uyğun qurun.
- **Non-fast-forward:** Başqası GitHub-a dəyişiklik göndəribsə, öz dəyişikliklərinizi qoruyaraq əvvəlcə `pull(repo)` edin və konfliktləri həll edin.
- **Səhv qovluq:** `repo.WorkingFolder` nəticəsini yoxlayın.

### Təhlükəsizlik

Bu repozitoriya `Public` olduqda kodlar hamıya görünə bilər. Məxfi məlumatlarla işləyirsinizsə, GitHub-da görünürlüğü `Private` edin. Giriş açarlarını, şifrələri və şəxsi məlumatları repozitoriyaya yükləməyin.

### Rəsmi istinadlar

- https://www.mathworks.com/help/matlab/ref/gitclone.html
- https://www.mathworks.com/help/matlab/ref/matlab.git.gitrepository.add.html
- https://www.mathworks.com/help/matlab/ref/matlab.git.gitrepository.commit.html
- https://www.mathworks.com/help/matlab/ref/matlab.git.gitrepository.push.html
