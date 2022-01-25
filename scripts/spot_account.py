import time
import click
import json
import requests
import base64

from spotinst_sdk2 import SpotinstSession


@click.group()
@click.pass_context
def cli(ctx, *args, **kwargs):
    ctx.obj = {}


@cli.command()
@click.argument('name', )
@click.option(
    '--token',
    required=False,
    help='Spotinst Token'
)
@click.pass_context
def create(ctx, *args, **kwargs):
    """Create a new Spot Account"""
    session = SpotinstSession(auth_token=kwargs.get('token'))
    ctx.obj['client'] = session.client("admin")
    result = ctx.obj['client'].create_account(kwargs.get('name'))
    click.echo(json.dumps(result))


@cli.command()
@click.argument('account-id')
@click.option(
    '--token',
    required=False,
    help='Spotinst Token'
)
@click.pass_context
def delete(ctx, *args, **kwargs):
    """Delete a Spot Account"""
    session = SpotinstSession(auth_token=kwargs.get('token'))
    ctx.obj['client'] = session.client("admin")
    ctx.obj['client'].delete_account(kwargs.get('account_id'))


@cli.command()
@click.argument('accountid')
@click.argument('credential')
@click.option(
    '--token',
    required=False,
    help='Spotinst Token'
)
def set_cloud_credentials(accountid, credential, **kwargs):
    """Set serviceaccount to a Spot Account"""
    temp = json.loads(base64.b64decode(credential))

    headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + kwargs.get('token')
    }
    url = 'https://api.spotinst.io/gcp/setup/credentials?accountId=' + accountid
    data = {"serviceAccount": temp}
    try:
        r = requests.post(headers=headers, json=data, url=url)
        r.raise_for_status()
        json_response = r.json()
        click.echo(json.dumps(json_response))
    except requests.exceptions.HTTPError as errh:
        print("Http Error:", errh)
        r = requests.post(headers=headers, json=data, url=url)
        json_response = r.json()
        click.echo(json.dumps(json_response))
    except requests.exceptions.ConnectionError as errc:
        print("Error Connecting:", errc)
    except requests.exceptions.Timeout as errt:
        print("Timeout Error:", errt)
    except requests.exceptions.RequestException as err:
        print("Oops: Something Else:", err)


@cli.command()
@click.option(
    '--filter',
    required=False,
    help='Return matching records. Syntax: key=value'
)
@click.option(
    '--attr',
    required=False,
    help='Return only the raw value of a single attribute'
)
@click.option(
    '--token',
    required=False,
    help='Spotinst Token'
)
@click.pass_context
def get(ctx, *args, **kwargs):
    """Returns ONLY the first match"""
    session = SpotinstSession(auth_token=kwargs.get('token'))
    ctx.obj['client'] = session.client("admin")
    result = ctx.obj['client'].get_accounts()
    if kwargs.get('filter'):
        k, v = kwargs.get('filter').split('=')
        result = [x for x in result if x[k] == v]
    if kwargs.get('attr'):
        if result:
            result = result[0].get(kwargs.get('attr'))
            click.echo(result)
    else:
        if result:
            click.echo(json.dumps(result[0]))


if __name__ == "__main__":
    cli()
