#!/usr/bin/env python3

from terraform_external_data import terraform_external_data
import json
import subprocess

def run_shell_command_with_parameters(command, work_dir=None):
    """Run Shell command and grab stdout, stderr and return code
    :param command: shell command in array form
    :param work_dir: working directory path, None for default
    :return error, stdout
    """
    command_arr = command.split(" ")
    res = subprocess.Popen(command_arr, cwd=work_dir, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    # to avoid process dead-locks
    stdout_bytes, stderr_bytes = res.communicate()
    stdout = stdout_bytes.decode() if stdout_bytes else ""
    stderr = stderr_bytes.decode() if stderr_bytes else ""
    return_code = res.returncode

    if return_code != 0:
        error_message = f"SHELL: non-zero error code" \
                        f" (return_code={return_code}, output={stdout}, err={stderr}) "
        
        return error_message, f"{stdout}\n{stderr}"
    return None, stdout


@terraform_external_data
def fetch(query):
    # Terraform requires the values you return be strings,
    # so terraform_external_data will error if they aren't.
    #print(query)
    #return ""
    names = query["list_of_vms"].split(",")
    ips = query["list_of_ips"].split(",")

    if len(names) != len(ips):
        raise Exception("The length of machine names and ips is not the same")

    vms = {}
    for index in range(len(names)):
        # VMs ping the neightbor in round robin way
        vm_to_ping_index = index + 1 if index < len(names) - 1 else 0
        vms[names[index]] = {
            "ip": ips[index],
            "vm_name_to_ping": names[vm_to_ping_index],
            "vm_ip_to_ping": ips[vm_to_ping_index]
        }

    res = {}
    for name, value in vms.items():
        err, _ = run_shell_command_with_parameters("sshpass -p '%s' ssh %s@%s ping -c 1 %s" %
            ('Pa$$w0rd', query['ssh_username'], value["ip"], value["vm_ip_to_ping"]))
        res["%s ping %s" % (name, value["vm_name_to_ping"])] = "pass" if not err else "fail"

    return res


if __name__ == '__main__':
    fetch()


