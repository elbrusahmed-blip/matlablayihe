# 20 kW GES: MATLAB R2024a-da avtomatik Simulink qurulması

## Dərhal başlamaq

Bu repozitoriyanın MATLAB-da əvvəlcədən klonlandığı nəzərdə tutulur.

MATLAB **Command Window**:

```matlab
repo = gitrepo;
pull(repo,Username="elbrusahmed-blip",Token=getSecret("GITHUB_TOKEN"));
build_GES20kW
```

Uğurlu olarsa, skript avtomatik:
1. 20 kW-lıq GES üçün blokları və onların əlaqələrini yaradır;
2. `GES20kW_SignalFlow_v1.slx` faylını lokal qovluqda saxlayır;
3. Simulink diaqramını açır;
4. 1 saniyəlik simulyasiyanı icra edir;
5. güc və üçfazalı gərginlik *istinad* qrafiklərini Scope bloklarında göstərir.

İlk icradan sonra `GES20kW_SignalFlow_v1.slx` artıq varsa, skript mövcud modeli açır, **onun üzərinə yazmır**. Yenidən yaratmaq istəyirsinizsə, əvvəl modelin öz nüsxəsini saxlayın, sonra faylın adını dəyişin.

## Texniki başlanğıc parametrləri

| Göstərici | Fərz edilən qiymət |
|---|---|
| PV nominal güc | 20 kW (STC) |
| Panel sayı | 40 × 500 W |
| Konfiqurasiya | 10 ardıcıl × 4 paralel |
| Modul Vmp | təxminən 41 V (nümunə) |
| PV string Vmp | təxminən 410 V |
| DC link | nominal 700 V (konseptual) |
| Boost duty (ideal) | təxminən 0.414 |
| İnverter AC | 3 fazalı, 400 V L-L, 50 Hz |
| Lokal yük | 5 kW |
| Transformator | 0.4/11 kV (konseptual) |
| Şəbəkə | 11 kV |
| MPPT faktor | 0.99 (sadələşdirilmiş, P&O deyil) |
| Boost faktor | 0.97 (ortalama) |
| İnverter faktor | 0.965 (ortalama) |
| LCL faktor | 0.995 (orta itki) |
| Transformator faktor | 0.985 (orta itki) |

## Test girişləri

- 0–0.4 s: Günəş şüalanması 1000 W/m².
- 0.4–1 s: Şüalanma 600 W/m².
- 0–0.7 s: Temperatur 25°C.
- 0.7–1 s: Temperatur 35°C.
- Şəbəkə sağlamlıq bayrağı: 1 (açıq). Onu 0 etsəniz, aktiv güc yolu bağlanır (sadə interlock).

Gözlənilən təxmini stasionar qiymətlər:
- STC zamanı `Ppv ≈ 20 kW`, `Pgrid export ≈ 13.24 kW`.
- G=600 W/m², T=35°C zamanı `Ppv ≈ 11.52 kW`, `Pgrid export ≈ 5.54 kW`.
- DC-link dinamikasına görə keçid zamanı qısa müddətli fərqlər normaldır.

## Diaqramda mövcud bloklar

- PV Array, irradiance, temperature;
- MPPT Controller (sadələşdirilmiş maksimum güc faktoru);
- DC-DC Boost Converter (ortalama itki faktoru);
- DC Link Capacitor (birinci tərtibli 20 ms hamarlama);
- Three-phase Inverter (ortalama);
- PWM Control (3 fazalı istinad sinusları, **real gate switching deyil**);
- LCL Filter (ortalama itki modeli);
- Circuit Breaker and Protection (grid healthy 0/1 ilə sadə güc kəsilməsi);
- Step-up Transformer (ortalama itki);
- Utility Grid (aktiv güc mübadiləsi);
- Local Load, Voltage Current Power Measurement;
- Scope-lar və To Workspace nəticə dəyişənləri.

## Nəticələr

`Power_20kW_Scope` — ardıcıllıqla PV, inverter və şəbəkəyə ixrac gücləri (W).
`ThreePhase_Reference_Scope` — 50 Hz üçfazalı sinusoidal **istinad** gərginlikləri.
`PCC_Measurements_Scope` — P (W), V_LL,RMS (V), I_RMS (A), f (Hz).

MATLAB workspace-də nəticələr:
- `GES_Ppv_W`
- `GES_Pinv_W`
- `GES_Pexport_W`

## ƏHƏMİYYƏTLİ: bu nədir, nə deyil?

Bu, **işləyən funksional enerji-axını Simulink prototipidir**. MATLAB və Simulink-in standart blokları ilə yaradılır. Nəticələr **real qısaqapanma, harmonika, PWM switching, MPPT P&O/ic incremental-conductance, fiziki kondensator, LCL rezonansı və PLL/PCC nəzarəti** hesabları üçün istifadə oluna **bilməz**. Blok adlarının fiziki elektrik komponentləri ilə eyniliyi onların Simscape elektrik portları olması demək deyil.

**Tam fiziki modelin növbəti versiyası** üçün Simscape Electrical / Specialized Power Systems modulları, real PV Array I–V əyrisi, P&O/IncCond MPPT, MOSFET/IGBT/Universal Bridge, DC-link capacitance, PLL, grid current controller, PWM gate switching, real LCL RLC, 400/11-kV transformator, grid və nasazlıq qoruma modelləri qurulmalıdır.

MATLAB-da sistemin imkanlarını yoxlamaq:

```matlab
ver
which('powergui')
```

`powergui` varsa, istifadəçidə Specialized Power Systems blokları mövcud ola bilər. Fiziki model üçün növbəti addım bu kitabxanaların dəqiq blok adlarını R2024a-da yoxlamaq və uyğun modeli avtomatik yaratmaqdır.

## Problemlər

- `Undefined function build_GES20kW`: qovluq səhvdir və ya `pull` tamamlanmayıb. `which build_GES20kW` yoxlayın.
- Simulink yoxdur: `ver` nəticəsini yoxlayın.
- Model yaradılıb, lakin `sim` xətası var: MATLAB-dakı **tam xəta mətnini** ötürün; skripti GitHub üzərindən düzəltmək mümkündür.
- Model uğurla yaranıbsa, onu GitHub-a yükləmək üçün əvvəlcə statusu yoxlayıb lokal commit/push edin.

Əlavə istinadlar:
- https://www.mathworks.com/help/simulink/programmatic-modeling.html
- https://www.mathworks.com/help/simulink/slref/add_block.html
- https://www.mathworks.com/help/simulink/slref/add_line.html
- https://www.mathworks.com/help/simulink/slref/save_system.html
