{

  programs.opencode = {
    enable = true;
    agents = {
      documentation-engineer = ./agent-documentation-engineer.md;
      mobile-developer = ./agent-mobile-developer.md;
      cloud-engineer = ./agent-cloud.md;
      terraform-engineer = ./agent-terraform.md;
      backend-developer = ./agent-backend-developer.md;
      frontend-developer = ./agent-frontend-developer.md;
    };

    skills = {

      git-release = ''
        ---
        name: git-release
        description: Create consistent releases and changelogs
        ---

        ## What I do

        - Draft release notes from merged PRs
        - Propose a version bump
        - Provide a copy-pasteable `gh release create` command
      '';
    };
  };
}
