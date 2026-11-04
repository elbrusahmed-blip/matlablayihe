function github_sync()
%GITHUB_SYNC Safely synchronize this MATLAB R2024a folder with GitHub.
% Initial one-time step:
%   1. Create a fine-grained PAT on GitHub scoped to "matlablayihe"
%      with Contents: Read and write.
%   2. Run setSecret("GITHUB_TOKEN") and paste the token in the dialog.
% After that, run: github_sync
%
% This script never displays your token and asks before staging files.

    repo = gitrepo;
    secretName = "GITHUB_TOKEN";
    userName = "elbrusahmed-blip";

    if ~isSecret(secretName)
        error("GitHub token tapilmadi. GitHub-da PAT yaradib setSecret(""GITHUB_TOKEN"") emrini icra edin.");
    end

    fprintf("GitHub sinxronizasiyasi: %s\n", repo.WorkingFolder);
    fprintf("Filial: %s\n", repo.CurrentBranch.Name);

    % Pull merges the current remote branch into the local branch.
    % Stop on conflicts or authentication errors; never force-push.
    fprintf("GitHub-daki deyisiklikler alinir...\n");
    pull(repo, Username=userName, Token=getSecret(secretName));

    % Review local changes before including files in a new commit.
    changedFiles = status(repo);
    if ~isempty(changedFiles)
        disp(changedFiles);
        fprintf("DIQQET: Sirlarinizi, sexsi melumatlari ve iri fayllari elave etmeyin.\n");
        choice = strtrim(input("Bu deyisiklikleri commit etmek isteyirsiniz? [y/N]: ", "s"));
        if strcmpi(choice, "y")
            add(repo, ".");
            commit(repo, Message="Update MATLAB project");
            fprintf("Yeni commit yaradildi.\n");
        else
            fprintf("Yeni deyisiklikler commit edilmedi. Evvelki commitler gonderile biler.\n");
        end
    else
        fprintf("Yeni local fayl deyisikliyi yoxdur.\n");
    end

    fprintf("GitHub-a gonderilir...\n");
    push(repo, Username=userName, Token=getSecret(secretName), Remote="origin");
    fprintf("Sinxronizasiya tamamlandi.\n");
end
