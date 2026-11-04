# matlablayihe — MATLAB / GitHub

Bu repozitoriya MATLAB R2024a skriptlərini, funksiyalarını və layihə fayllarını GitHub ilə versiyalaşdırmaq üçün hazırlanıb.

**GitHub:** https://github.com/elbrusahmed-blip/matlablayihe  
**Clone URL:** `https://github.com/elbrusahmed-blip/matlablayihe.git`  
**Əsas filial:** `main`

## MATLAB R2024a-da ilk qoşulma

1. MATLAB proqramını açın.
2. **Command Window** bölməsində aşağıdakı əmri işə salın:

```matlab
repo = gitclone("https://github.com/elbrusahmed-blip/matlablayihe.git");
cd(repo.WorkingFolder)
```

Bu əmrlər GitHub-dakı repozitoriyanı MATLAB-ın **Current Folder** qovluğunun daxilində `matlablayihe` adlı yeni qovluğa köçürür və həmin qovluğa keçir. Eyni adda qovluq varsa, əvvəlcə başqa valideyn qovluq seçin.

3. Əlaqəni və nümunə skripti yoxlayın:

```matlab
repo = gitrepo;
disp(repo.WorkingFolder)
run("baslangic.m")
```

## Faylları GitHub-a göndərmək

MATLAB-da yeni `.m`, `.mlx` və ya `.slx` faylını bu repozitoriyanın daxilində yaradın. Daha sonra:

```matlab
repo = gitrepo;
add(repo,".");  % yeni faylları qeydiyyata al
commit(repo,Message="MATLAB layihə faylları əlavə olundu");
push(repo);
```

**Vacib:** `commit` öncəsi dəyişdirilmiş faylların düzgün saxlandığını yoxlayın. `push` zamanı GitHub giriş icazəsi tələb oluna bilər. GitHub hesabının parolu əvəzinə **Personal Access Token (PAT)** istifadə olunur; tokeni kodun içinə yazmayın və repozitoriyaya yükləməyin.

## GitHub-dakı yenilikləri almaq

```matlab
repo = gitrepo;
pull(repo);
```

## Faylların təyinatı

- `baslangic.m` — MATLAB bağlantısını və əsas funksiyaları sınamaq üçün sadə nümunə.
- `.gitignore` — müvəqqəti MATLAB/Simulink fayllarını və yerli məxfi məlumatları Git-dən kənar saxlayır.
- `.gitattributes` — MATLAB/Simulink ikili fayllarını binar formatda saxlayır.
- `docs/MATLAB_R2024a_qosulma.md` — ətraflı addımlar və mümkün xətalar.

**Görünürlük xəbərdarlığı:** Bu repozitoriya hazırda `Public` ola bilər. Məxfi kod və ya məlumat əlavə etməzdən əvvəl GitHub Settings → General → Change repository visibility bölməsindən `Private` seçin.

## Mənbələr

- [MathWorks: gitclone](https://www.mathworks.com/help/matlab/ref/gitclone.html)
- [MathWorks: Git Repository](https://www.mathworks.com/help/matlab/ref/matlab.git.gitrepository.html)
