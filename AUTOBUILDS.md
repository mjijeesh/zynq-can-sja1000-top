# Automatic FPGA image builds

- scheduled nightly job in "master" (microzed_apo_canfd_test) branch
    - script
        - check out branch "autobuild"
        - update submodules with IPs
        - commit and push all changes (if any)
    - uses gitlab deploy key for pushing to the repo
- on push in "autobuild" branch
    - script
        - build image and keep it in artifacts
