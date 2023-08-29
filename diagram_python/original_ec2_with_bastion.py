from diagrams import Cluster, Diagram, Edge, Node

from diagrams.aws import general, compute, network, security, management

diag_graph_attr = {
    "margin": ".1",
    "pad"   : ".1"
}

aws_graph_attr = {
    "style"   : "solid",
    "bgcolor" : "transparent",
    "pencolor": "chocolate1",
    "penwidth": "4",
    "margin"  : "30",
    "pad"     : "15"
}

vpc_graph_attr = {
    "style"  : "solid",
    "bgcolor" : "transparent",
    "pencolor": "cadetblue4",
    "penwidth": "2"
}

public_subnet_attr = {
    "pencolor": "transparent",
    "penwidth": "0",
    "bgcolor": "lightcyan"
}

private_subnet_attr = {
    "pencolor": "transparent",
    "penwidth": "0",
    "bgcolor": "#baf5d5"
}

sg_graph_attr = {
    "pencolor": "red",
    "penwidth": "2",
    "style": "dashed"
}

#######################################################
# Setup Some Input Variables for Easier Customization #
#######################################################
show = False
direction = "LR"
smaller = "0.8"


with Diagram(
    name="Original EC2 Access via ssh and bastion",
    direction=direction,
    show=show,
) as diag:
    
    user = general.User("user")
    key = security.IdentityAndAccessManagementIamAddOn("", fixedsize="true", height="0.75")
    
    with Cluster("AWS Account", graph_attr=aws_graph_attr):


        # Cluster = Group, so this outline will group all the items nested in it automatically
        with Cluster("vpc", graph_attr=vpc_graph_attr):
            igw_gateway = network.InternetGateway("igw")

            # Subcluster for grouping inside the vpc
            with Cluster("public subnet", graph_attr= public_subnet_attr):
                with Cluster("security group", graph_attr=sg_graph_attr):
                    bastion = compute.EC2("bastion EC2 instance")

            # Another subcluster equal to the subnet one above it
            with Cluster("private subnet", graph_attr=private_subnet_attr):
                with Cluster("security group", graph_attr=sg_graph_attr):
                    private_server = compute.EC2("private\n EC2 instance", pin="true", pos="1,1")

    user >> key >> Edge(label="ssh") >> igw_gateway >> bastion >> private_server 

diag
