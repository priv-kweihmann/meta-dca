# Configuration for `filelife` module

| var                             |                           purpose                            |                   type |                                                                  default |
| ------------------------------- | :----------------------------------------------------------: | ---------------------: | -----------------------------------------------------------------------: |
| DCA_FILELIFE_ACCEPTABLE_FSTYPE  | List of filesystem type considered safe for frequent changes | space-separated-string | "bpf cgroup debugfs dev devpts devtmpfs mqueue proc sysfs tmpfs tracefs" |
| DCA_FILELIFE_DURATION_THRESHOLD |            Minimum lifespan of a file in seconds             |           float string |                                                                   "10.0" |
