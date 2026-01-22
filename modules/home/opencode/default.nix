{

  programs.opencode = {
    enable = true;
    agents = {
      documentation-engineer = ./agent-documentation-engineer.md;
      mobile-developer = ./agent-mobile-developer.md;
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
