#!/usr/bin/python3
import argparse
import os.path
from datetime import datetime

FILE_PATH = os.path.dirname(os.path.realpath(__file__))
TEMPLATE_PATH = FILE_PATH + '/templates/'


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output_hdl_type', choices=['sv', 'v', 'vhd'], metavar='sv/v/vhd', type=str, help='the HDL type of output file .e.g sv/v/vhd', required=True)
    parser.add_argument('--output_module_type', choices=['tb', 'pipeline'], metavar='pipeline/tb', type=str, help='module created type .e.g tb or pipeline', required=True)
    parser.add_argument('--pipelen', type=int, help='the lenght of the pipeline for pipeline modules', default=2)
    parser.add_argument('--module_name', type=str, metavar='<module_name>', help='the output name of module and file', required=True)
    parser.add_argument('--author_name', type=str, metavar='[author name]', help='the name of the author')
    parser.add_argument('--company_name', type=str, metavar='[company name]', help='te company of the author')
    parser.add_argument('--description', type=str, metavar='[description]', help='description written in the header')
    return parser.parse_args()

def get_testbench_path(args):
    path=''
    if args.output_hdl_type == 'sv':
        path = TEMPLATE_PATH + 'sv/testbench.txt'
    elif args.output_hdl_type == 'v':
        path = TEMPLATE_PATH + 'v/testbench.txt'
    elif args.output_hdl_type == 'vhd':
        path = TEMPLATE_PATH + 'vhd/testbench.txt'
    return path



def get_header_path(args):
    path=''
    if args.output_hdl_type == 'sv':
        path = TEMPLATE_PATH + 'sv/header.txt'
    elif args.output_hdl_type == 'v':
        path = TEMPLATE_PATH + 'v/header.txt'
    elif args.output_hdl_type == 'vhd':
        path = TEMPLATE_PATH + 'vhd/header.txt'
    return path


def create_header(template_header_path, args):
    t = ''
    with open(template_header_path, 'r') as thp:
        t = thp.read()
        t = t.replace('{{AUTHOR}}', ('', args.author_name)[args.author_name is not None])
        t = t.replace('{{COMPANY}}', ('', args.company_name)[args.company_name is not None])
        t = t.replace('{{MODULE_NAME}}', args.module_name)
        t = t.replace('{{DESCRIPTION}}', ('', args.description)[args.description is not None])
        t = t.replace('{{DATE}}', datetime.today().strftime('%d/%m/%Y'))
    return t


def create_pipeline(args):
    return 'mon module'


def create_testbench(template_testbench_path, args):
    t = ''
    with open(template_testbench_path, 'r') as ttp:
        t = ttp.read()
    return t


def main():
    output_content = ''
    args = get_args()
    template_header_path = get_header_path(args)
    output_content = create_header(template_header_path, args)
    if args.output_module_type == 'pipeline':
        output_content = output_content + '\n' + create_pipeline(args)
    else:
        template_testbench_path = get_testbench_path(args)
        output_content = output_content + '\n' + create_testbench(template_testbench_path, args)

    name_o = args.module_name + '.' + args.output_hdl_type
    with open(name_o, 'w') as output_file:
        output_file.write(output_content)


if __name__ == '__main__':
    main()
