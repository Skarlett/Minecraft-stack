use serenity::{
    client::Client,
    prelude::{EventHandler, Context},
    
    framework::standard::{
        StandardFramework,
        CommandResult,
        macros::{
            command,
            group
        }
    },

    model::{
        channel::Message,
        gateway::Ready
    }
};

use std::{
    process::{Command},
    env
};


// Does this system need sudo?
const SUDO: bool = false;
const PREFIX: &'static str = "-";
const CONSOLE: u64 = 667008250666811393;

enum Status {
    Stopped,
    Running
}

fn cmd(c: &str) -> Command {
    let mut cmd = Command::new("systemctl");

    if SUDO {
        cmd = Command::new("sudo");
        cmd.arg("systemctl");
    }

    cmd.arg(c)
      .arg("minecraft@vanilla");
    
    return cmd
}

fn checkstatus() -> Status {
    match cmd("is-active").status()
    {
        Ok(s) => {
            if s.success() {
                return Status::Running
            }
            return Status::Stopped
        },
        Err(_) => return Status::Stopped,
    }  
}


#[group]
#[commands(start, restart, stop, status)]
struct MC;
struct Handler;

impl EventHandler for Handler {
    fn ready(&self, _ctx: Context, evt: Ready) {
        println!("{} Online", evt.user.name)
    }
}


#[command]
fn start(ctx: &mut Context, msg: &Message) -> CommandResult {
    if msg.channel(&ctx).unwrap().id() == CONSOLE {    
        match checkstatus() {
            Status::Running => {
                msg.reply(ctx, "Server's Running?!")?;
            },
            
            Status::Stopped => {
                match cmd("start").status()
                {
                    Ok(_) => {
                        msg.reply(ctx, "Server starting!")?;
                    },
                    Err(e) => {
                        msg.reply(ctx, format!("{}", e))?;
                    }

                }
            }
        }
    }

    Ok(())
}


#[command]
fn restart(ctx: &mut Context, msg: &Message) -> CommandResult {
    if msg.channel(&ctx).unwrap().id() == CONSOLE {
        match cmd("restart").status()
        {
            Ok(_) => {
                msg.reply(ctx, "Server starting!")?;
            },
            Err(e) => {
                msg.reply(ctx, format!("{}", e))?;
            }

        }
    }

    Ok(())
}


#[command]
fn stop(ctx: &mut Context, msg: &Message) -> CommandResult {
    if msg.channel(&ctx).unwrap().id() == CONSOLE {
        
        match checkstatus() {
            Status::Running => {
            
                match cmd("stop").status()
                {
                    Ok(_) => {
                        msg.reply(ctx, "Stopping")?;
                    },

                    Err(e) => {
                        msg.reply(ctx, format!("{}", e))?;
                    }
                }
            
            },
            
            Status::Stopped => {
                msg.reply(ctx, "Server appears not to be running")?;
            }
        }
    }

    Ok(())
}


#[command]
fn status(ctx: &mut Context, msg: &Message) -> CommandResult {
    match checkstatus() {
        Status::Running => {
            msg.reply(ctx, "Server is running")?;
        },
            
        Status::Stopped => {
            msg.reply(ctx, "Server appears not to be running")?;
        }
    }

    Ok(())
}



fn main() {
    let token = env::var("DISCORD_TOKEN")
        .expect("No discord token, use `DISCORD_TOKEN=\"...\"`");

    loop {
        let mut client = Client::new(token.clone(), Handler)
            .expect("Error creating client");
        client.with_framework(StandardFramework::new()
            .configure(|c| c.prefix(PREFIX))
            .group(&MC_GROUP));

        // start listening for events by starting a single shard
        if let Err(why) = client.start() {
            println!("An error occurred while running the client: {:?}", why);
        }
    }
}
