# MATLAB R2024a: GitHub-a bir komanda ilə göndərmə

Bu fayllar **elbrusahmed-blip/matlablayihe** repozitoriyası üçün yaradılıb.

## GitHub-dakı hazırlıq (tamamlandı)

- MATLAB skriptləri və Git parametrləri yüklənib.
- `github_sync.m` — sinxronizasiya funksiyası əlavə edilib.
- GitHub repozitoriyası: https://github.com/elbrusahmed-blip/matlablayihe

## Hesab sahibinin tamamlamalı olduğu addım

GitHub hesabında özünüz fine-grained **Personal Access Token** yaradın:
https://github.com/settings/personal-access-tokens/new

- Resource owner: `elbrusahmed-blip`
- Repository access: `Only select repositories` → `matlablayihe`
- Repository permissions: `Contents` → `Read and write`
- Yalnız lazım olan müddətə etibarlılıq təyin edin.

**Tokeni ChatGPT-yə, kod faylına və GitHub repozitoriyasına əlavə etməyin.**

MATLAB R2024a **Command Window**-da tokeni gizli pəncərəyə daxil edin:

```matlab
setSecret("GITHUB_TOKEN")
```

Bu əmri bir dəfə yerinə yetirmək kifayətdir (tokenin müddəti bitənədək).

## İndi yerli faylları uyğunlaşdırın

Əgər daha əvvəl `git_test.txt` üçün lokal commit etmisinizsə, GitHub-da yeni fayllar yarandığından ilk dəfə remote dəyişikliklərini də endirin:

```matlab
repo = gitrepo;
pull(repo,Username="elbrusahmed-blip",Token=getSecret("GITHUB_TOKEN"));
```

Bu, fərqli fayllara aid dəyişiklikləri adətən avtomatik birləşdirir. Konflikt çıxarsa, `push` etmədən öncə onu həll edin.

## Sonra sadəcə bu əmri işlədin

```matlab
github_sync
```

`github_sync`:
1. GitHub-dakı dəyişiklikləri alır;
2. Lokal dəyişikliklər varsa, onları commit etmək üçün icazə istəyir;
3. Yalnız təsdiqlədikdən sonra əlavə faylları commit edir;
4. Mövcud commitləri GitHub-a göndərir.

**Diqqət:** `y` yazarkən yoxlanmamış/məxfi faylların repozitoriyada olmadığından əmin olun. `.gitignore` kömək edir, amma bütün məxfi məlumatları avtomatik aşkar etmir.

Əgər istəsəniz, `github_sync` əmrinə qədər heç bir əlavə fayl commit etməyə bilərsiniz. Yerli əvvəlki `git_test.txt` commit-i push olunacaq.

## Yoxlama

GitHub-da `git_test.txt` faylına baxın:
https://github.com/elbrusahmed-blip/matlablayihe

GitHub `Public` görünürsə və kodlarınız məxfidirsə, əvvəlcə repozitoriyanı `Private` edin. Bu dəyişiklik hesabın GitHub Settings panelində edilir.

Rəsmi MathWorks istinadları:
- https://www.mathworks.com/help/matlab/ref/setsecret.html
- https://www.mathworks.com/help/matlab/ref/matlab.git.gitrepository.pull.html
- https://www.mathworks.com/help/matlab/ref/matlab.git.gitrepository.push.html
