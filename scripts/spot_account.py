import click
import base64

from spotinst_sdk2 import SpotinstSession
from spotinst_sdk2.models.setup.gcp import *


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
    required=True,
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
    required=True,
    help='Spotinst Token'
)
@click.pass_context
def set_cloud_credentials(ctx, **kwargs):
    """Set serviceaccount to a Spot Account"""
    session = SpotinstSession(auth_token=kwargs.get('token'))
    ctx.obj['client2'] = session.client("setup_gcp")
    ctx.obj['client2'].account_id = kwargs.get('account_id')
    credential_json = json.loads(base64.b64decode(kwargs.get('credential')))
    serviceaccount = ServiceAccount(type=credential_json.get("type"), project_id=credential_json.get("project_id"),
                                    private_key_id=credential_json.get("private_key_id"),
                                    private_key=credential_json.get("private_key"),
                                    client_email=credential_json.get("client_email"),
                                    client_id=credential_json.get("client_id"),
                                    auth_uri=credential_json.get("auth_uri"),
                                    token_uri=credential_json.get("token_uri"),
                                    auth_provider_x509_cert_url=credential_json.get("auth_provider_x509_cert_url"),
                                    client_x509_cert_url=credential_json.get("client_x509_cert_url"))
    gcpcredentials = GcpCredentials(serviceAccount=serviceaccount)
    result = ctx.obj['client2'].set_credentials(gcpcredentials)
    click.echo(json.dumps(result))


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
    required=True,
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
            fail_string = {'account_id': '', 'organization_id': ''}
            click.echo(json.dumps(fail_string))
    else:
        if result:
            click.echo(json.dumps(result[0]))
        else:
            fail_string = {'account_id': '', 'organization_id': ''}
            click.echo(json.dumps(fail_string))


if __name__ == "__main__":
    cli()
