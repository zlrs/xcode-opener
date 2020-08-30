#!/usr/bin/python3
import sys
import os
import shutil
import click
import version_check


def getXCodeProjectOrWorkspaceFilePath(dirPath) -> str:
    def hasSameFileName(file1: str, file2: str) -> bool:
        basename1 = os.path.basename(file1)
        basename2 = os.path.basename(file2)
        return os.path.splitext(basename1)[0] == os.path.splitext(basename2)[0]

    def chooseFromPrompt(workspaceFile: [str], projectFile: [str]) -> str:
        files = workspaceFile + projectFile
        prompt = ''
        cnt = 1
        for file in files:
            line = '%d. %s\n' % (cnt, os.path.basename(file))
            prompt += line
            cnt += 1
        prompt += 'please choose the file to operate: '
        try:
            index = int(input(prompt))
            return files[index - 1]
        except (ValueError, IndexError) as e:
            print('Invalid Argument: please enter a valid index. ')
            print(e)
            exit(1)
        return ''

    workspace_ext = '.xcworkspace'
    proj_ext = '.xcodeproj'
    workspaceFile = []
    projectFile = []
    for entry in os.listdir(dirPath):
        if(entry.endswith(workspace_ext)):
            _aWorkspaceFile = os.path.join(dirPath, entry)
            workspaceFile.append(_aWorkspaceFile)
        elif entry.endswith(proj_ext):
            _aProjectFile = os.path.join(dirPath, entry)
            projectFile.append(_aProjectFile)

    if len(workspaceFile) == 0 and len(projectFile) == 0:  # dirPath下没有XCode项目
        return ''
    elif len(workspaceFile) == 0 and len(projectFile) == 1:  # 只有1个proj文件
        return projectFile[0]
    elif len(workspaceFile) == 1 and len(projectFile) == 0:  # 只有1个workspace文件
        return workspaceFile[0]
    elif len(workspaceFile) == 1 and len(workspaceFile) == 1 and hasSameFileName(workspaceFile[0], projectFile[0]):
        return workspaceFile[0]  # 认为两文件同属一个XCode项目，忽略proj文件
    else:
        return chooseFromPrompt(workspaceFile, projectFile)  # 存在多个项目，提示用户手动选择


def openInXcode(dirPath):
    file_path = getXCodeProjectOrWorkspaceFilePath(dirPath)
    if file_path:
        cmd = 'open "%s"' % file_path
        print(cmd)
        os.system(cmd)
    else:
        print('No .xcodeproj / .xcworkspace file is found. ')


def removeIndex(dirPath):
    """Remove the index directory of the project"""
    derived_data_path = os.path.expanduser('~/Library/Developer/Xcode/DerivedData/')

    proj_file_path = getXCodeProjectOrWorkspaceFilePath(dirPath)
    proj_name = os.path.splitext(os.path.basename(proj_file_path))[0]
    if proj_name is None or len(proj_name) < 1:
        return 1

    proj_dir_list = os.listdir(derived_data_path)
    for proj_dir in proj_dir_list:
        if proj_dir.startswith(proj_name):
            proj_index_dir = os.path.join(derived_data_path, proj_dir, 'Index')
            print('Removing: ' + proj_index_dir)
            shutil.rmtree(proj_index_dir)

    return 0


@click.command()
@click.argument('path', default='.')
@click.option('--rmindex', is_flag=True)
def xc(path, rmindex):
    """A CLI tool that opens XCode project from Terminal. 
    Auto detect `.xcodeproj` file or `.xcworkspace` file. 
    For example, use it to quickly open a workspace after `pod install`. 
    """
    if path == '':
        path = os.getcwd()
    
    abs_path = os.path.expanduser(path)
    
    exit_val = 0
    if os.path.exists(abs_path):
        if rmindex:
            removeIndex(abs_path)
        else:
            openInXcode(abs_path)
    else:
        click.echo('input path not exist.')
        exit_val = 1
    
    version_check.run()
    exit(exit_val)


if __name__ == '__main__':
    xc()
