from diagrams import Cluster, Diagram, Edge, Node

from diagrams.aws import general, compute, network, security, management

diag_graph_attr = {
    "margin": ".1",
    "pad"   : ".1",
    "layout": "neato"
}

aws_graph_attr = {
    "style"   : "solid",
    "bgcolor" : "transparent",
    "pencolor": "chocolate1",
    "penwidth": "4",
    "margin"  : "30",
    "pad"     : "25"
}

vpc_graph_attr = {
    "style"  : "solid",
    "bgcolor" : "transparent",
    "pencolor": "cadetblue4",
    "penwidth": "2",
    "margin": "10"
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
    name="EC2 Access via SSM and Session Manager",
    direction=direction,
    show=show,
) as diag:
    
    user = general.User("user", pos = "0,4!")
    
    with Cluster("AWS Account", graph_attr=aws_graph_attr):

        ssm = management.SystemsManager("SSM\nSession Manager", pos="2,2!")


        # Cluster = Group, so this outline will group all the items nested in it automatically
        with Cluster("vpc", graph_attr=vpc_graph_attr):
            igw_gateway = network.InternetGateway("igw", pos = "2,2!")

            # Subcluster for grouping inside the vpc
            with Cluster("public subnet", graph_attr= public_subnet_attr):
                NATgateway = network.NATGateway("NAT Gateway", pos="6,2!")

            # Another subcluster equal to the subnet one above it
            with Cluster("private subnet 1", graph_attr=private_subnet_attr):
                with Cluster("security group 1", graph_attr=sg_graph_attr):
                    private_server1 = compute.EC2("private\n EC2 instance 1", pos = "4,2!")

            with Cluster("private subnet 2", graph_attr=private_subnet_attr):
                with Cluster("security group 2", graph_attr=sg_graph_attr):
                    endpoint = network.Endpoint("endpoints")

                with Cluster("security group 3", graph_attr=sg_graph_attr):
                    private_server2 = compute.EC2("private\n EC2 instance 2")


    user >> ssm >> private_server1 >> NATgateway >> igw_gateway >> user
    # private_server1 >> Edge(style="dashed") >> NATgateway >> Edge(style="dashed") >> igw_gateway >> user
    # ssm >> endpoint >> private_server2
    # endpoint >> Edge(style="dashed") >> igw_gateway

diag
